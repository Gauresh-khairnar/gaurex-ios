const fs = require('fs');

function testMachoEnd(machoBuf) {
  // Read Mach-O 64 header
  const magic = machoBuf.readUInt32LE(0);
  if (magic !== 0xFEEDFACF) {
    throw new Error('Not Mach-O 64');
  }
  const ncmds = machoBuf.readUInt32LE(16);
  const sizeofcmds = machoBuf.readUInt32LE(20);

  let p = 32;
  let csCmd = null;
  let linkeditCmd = null;

  for (let i = 0; i < ncmds; i++) {
    const cmd = machoBuf.readUInt32LE(p);
    const cmdsize = machoBuf.readUInt32LE(p + 4);

    if (cmd === 0x19) { // LC_SEGMENT_64
      const segname = machoBuf.toString('utf8', p + 8, p + 24).replace(/\0/g, '');
      const vmaddr = machoBuf.readBigUInt64LE(p + 24);
      const vmsize = machoBuf.readBigUInt64LE(p + 32);
      const fileoff = machoBuf.readBigUInt64LE(p + 40);
      const filesize = machoBuf.readBigUInt64LE(p + 48);

      if (segname === '__LINKEDIT') {
        linkeditCmd = { fileoff: Number(fileoff), filesize: Number(filesize), vmaddr, vmsize };
      }
    } else if (cmd === 0x1D) { // LC_CODE_SIGNATURE
      const dataoff = machoBuf.readUInt32LE(p + 8);
      const datasize = machoBuf.readUInt32LE(p + 12);
      csCmd = { dataoff, datasize };
    }
    p += cmdsize;
  }

  console.log('File total length:', machoBuf.length);
  console.log('Linkedit segment:', linkeditCmd);
  console.log('Code signature cmd:', csCmd);

  if (!csCmd) throw new Error('No LC_CODE_SIGNATURE found');
  if (!linkeditCmd) throw new Error('No __LINKEDIT found');

  const csEnd = csCmd.dataoff + csCmd.datasize;
  const linkeditEnd = linkeditCmd.fileoff + linkeditCmd.filesize;

  console.log(`csEnd = ${csEnd}, linkeditEnd = ${linkeditEnd}, fileLen = ${machoBuf.length}`);

  if (csEnd !== machoBuf.length) {
    console.error(`FAIL: csEnd (${csEnd}) !== fileLen (${machoBuf.length})! Trailing bytes = ${machoBuf.length - csEnd}`);
    return false;
  }
  if (linkeditEnd !== machoBuf.length) {
    console.error(`FAIL: linkeditEnd (${linkeditEnd}) !== fileLen (${machoBuf.length})!`);
    return false;
  }

  // Check SuperBlob
  const superBlobMagic = machoBuf.readUInt32BE(csCmd.dataoff);
  const superBlobLen = machoBuf.readUInt32BE(csCmd.dataoff + 4);
  console.log(`SuperBlob magic: 0x${superBlobMagic.toString(16).toUpperCase()}, length: ${superBlobLen}`);

  if (superBlobMagic !== 0xFADE0CC0) {
    console.error('FAIL: SuperBlob magic mismatch');
    return false;
  }
  if (superBlobLen !== csCmd.datasize) {
    console.error(`FAIL: SuperBlob length (${superBlobLen}) !== cs.datasize (${csCmd.datasize})`);
    return false;
  }

  console.log('SUCCESS: Code signature is at the exact end of the Mach-O slice and SuperBlob is valid!');
  return true;
}

// Generate with exact end alignment
function generateAlignedMacho() {
  const pageSize = 0x4000; // 16KB
  const csSize = 0x4000;   // 16KB reserved for signature
  const csOffset = pageSize * 2; // 0x8000
  const fileSize = csOffset + csSize; // 0xC000 (49152)

  const buf = Buffer.alloc(fileSize, 0);
  let p = 0;

  function writeU32(val) { buf.writeUInt32LE(val, p); p += 4; }
  function writeU64(val) { buf.writeBigUInt64LE(BigInt(val), p); p += 8; }
  function writeStringPadded(str, len) {
    const b = Buffer.from(str, 'utf8');
    b.copy(buf, p, 0, Math.min(b.length, len));
    p += len;
  }

  // Header (32 bytes)
  writeU32(0xFEEDFACF); // MH_MAGIC_64
  writeU32(0x0100000C); // CPU_TYPE_ARM64
  writeU32(0x00000000); // CPU_SUBTYPE_ARM64_ALL
  writeU32(0x00000002); // MH_EXECUTE
  const ncmdsOffset = p;
  writeU32(0);
  const sizeofcmdsOffset = p;
  writeU32(0);
  writeU32(0x00200085); // flags: MH_NOUNDEFS | MH_DYLDLINK | MH_TWOLEVEL | MH_PIE
  writeU32(0);          // reserved

  const commandsStart = p;
  let commandCount = 0;

  // CMD 1: LC_SEGMENT_64 __PAGEZERO
  commandCount++;
  writeU32(0x19);
  writeU32(72);
  writeStringPadded('__PAGEZERO', 16);
  writeU64(0);
  writeU64(0x100000000n);
  writeU64(0);
  writeU64(0);
  writeU32(0); writeU32(0); writeU32(0); writeU32(0);

  // CMD 2: LC_SEGMENT_64 __TEXT (152 bytes)
  commandCount++;
  writeU32(0x19);
  writeU32(152);
  writeStringPadded('__TEXT', 16);
  writeU64(0x100000000n);
  writeU64(pageSize);
  writeU64(0);
  writeU64(pageSize);
  writeU32(7); writeU32(5); writeU32(1); writeU32(0);

  // Section: __text (80 bytes)
  const textOffset = 0x1000;
  writeStringPadded('__text', 16);
  writeStringPadded('__TEXT', 16);
  writeU64(0x100000000n + BigInt(textOffset));
  writeU64(16);
  writeU32(textOffset);
  writeU32(2); writeU32(0); writeU32(0);
  writeU32(0x80000400);
  writeU32(0); writeU32(0); writeU32(0);

  // CMD 3: LC_SEGMENT_64 __DATA (72 bytes)
  commandCount++;
  writeU32(0x19);
  writeU32(72);
  writeStringPadded('__DATA', 16);
  writeU64(0x100000000n + BigInt(pageSize));
  writeU64(pageSize);
  writeU64(pageSize);
  writeU64(pageSize);
  writeU32(3); writeU32(3); writeU32(0); writeU32(0);

  // CMD 4: LC_SEGMENT_64 __LINKEDIT (72 bytes)
  commandCount++;
  writeU32(0x19);
  writeU32(72);
  writeStringPadded('__LINKEDIT', 16);
  writeU64(0x100000000n + BigInt(csOffset));
  writeU64(csSize);   // vmsize equals csSize
  writeU64(csOffset); // fileoff equals csOffset
  writeU64(csSize);   // filesize equals csSize -> ends exactly at csOffset + csSize = fileSize!
  writeU32(1); writeU32(1); writeU32(0); writeU32(0);

  // CMD 5: LC_LOAD_DYLINKER
  commandCount++;
  writeU32(0x0E);
  writeU32(32);
  writeU32(12);
  writeStringPadded('/usr/lib/dyld', 20);

  // CMD 6: LC_BUILD_VERSION
  commandCount++;
  writeU32(0x32);
  writeU32(24);
  writeU32(2); // iOS
  writeU32((17 << 16) | (0 << 8));
  writeU32((17 << 16) | (0 << 8));
  writeU32(0);

  // CMD 7: LC_MAIN
  commandCount++;
  writeU32(0x80000028);
  writeU32(24);
  writeU64(textOffset);
  writeU64(0);

  // CMD 8: LC_CODE_SIGNATURE (16 bytes)
  commandCount++;
  writeU32(0x1D);
  writeU32(16);
  writeU32(csOffset);
  writeU32(csSize); // csOffset + csSize === fileSize!

  const sizeofcmds = p - commandsStart;
  buf.writeUInt32LE(commandCount, ncmdsOffset);
  buf.writeUInt32LE(sizeofcmds, sizeofcmdsOffset);

  // ARM64 instructions at textOffset: mov x0, #0; ret
  buf.writeUInt32LE(0xD2800000, textOffset);
  buf.writeUInt32LE(0xD65F03C0, textOffset + 4);

  // SuperBlob at csOffset
  buf.writeUInt32BE(0xFADE0CC0, csOffset); // magic
  buf.writeUInt32BE(csSize, csOffset + 4);  // length
  buf.writeUInt32BE(0, csOffset + 8);       // count = 0

  return buf;
}

const macho = generateAlignedMacho();
testMachoEnd(macho);
