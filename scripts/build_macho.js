const fs = require('fs');
const path = require('path');

function createMachoBinary() {
  const pageSize = 0x4000; // 16KB standard page on iOS arm64
  const fileSize = 0xC000; // 48KB total file: TEXT (16KB) + DATA (16KB) + LINKEDIT (16KB)
  const buf = Buffer.alloc(fileSize, 0);

  let p = 0; // write pointer

  // Helper write functions
  function writeU32(val) {
    buf.writeUInt32LE(val, p);
    p += 4;
  }
  function writeU64(val) {
    buf.writeBigUInt64LE(BigInt(val), p);
    p += 8;
  }
  function writeStringPadded(str, len) {
    const b = Buffer.from(str, 'utf8');
    b.copy(buf, p, 0, Math.min(b.length, len));
    p += len;
  }

  // 1. Mach-O Header (32 bytes)
  const MH_MAGIC_64 = 0xFEEDFACF;
  const CPU_TYPE_ARM64 = 0x0100000C;
  const CPU_SUBTYPE_ARM64_ALL = 0x00000000;
  const MH_EXECUTE = 0x00000002;
  const MH_FLAGS = 0x00200085; // MH_NOUNDEFS | MH_DYLDLINK | MH_TWOLEVEL | MH_PIE

  const headerOffset = 0;
  writeU32(MH_MAGIC_64);
  writeU32(CPU_TYPE_ARM64);
  writeU32(CPU_SUBTYPE_ARM64_ALL);
  writeU32(MH_EXECUTE);
  
  const ncmdsOffset = p;
  writeU32(0); // placeholder for ncmds
  const sizeofcmdsOffset = p;
  writeU32(0); // placeholder for sizeofcmds
  writeU32(MH_FLAGS);
  writeU32(0); // reserved

  const commandsStart = p;
  let commandCount = 0;

  // CMD 1: LC_SEGMENT_64 __PAGEZERO (72 bytes)
  commandCount++;
  writeU32(0x19); // LC_SEGMENT_64
  writeU32(72);   // cmdsize
  writeStringPadded('__PAGEZERO', 16);
  writeU64(0);           // vmaddr
  writeU64(0x100000000n); // vmsize: 4GB
  writeU64(0);           // fileoff
  writeU64(0);           // filesize
  writeU32(0);           // maxprot
  writeU32(0);           // initprot
  writeU32(0);           // nsects
  writeU32(0);           // flags

  // CMD 2: LC_SEGMENT_64 __TEXT (72 + 80 = 152 bytes)
  commandCount++;
  writeU32(0x19); // LC_SEGMENT_64
  writeU32(152);  // cmdsize: 72 + 80
  writeStringPadded('__TEXT', 16);
  writeU64(0x100000000n); // vmaddr
  writeU64(pageSize);     // vmsize: 16KB
  writeU64(0);           // fileoff
  writeU64(pageSize);     // filesize: 16KB
  writeU32(7);           // maxprot: rwx
  writeU32(5);           // initprot: r-x
  writeU32(1);           // nsects
  writeU32(0);           // flags

  // Section 1 of __TEXT: __text (80 bytes)
  const textOffset = 0x1000;
  writeStringPadded('__text', 16);
  writeStringPadded('__TEXT', 16);
  writeU64(0x100000000n + BigInt(textOffset)); // addr
  writeU64(16);          // size (16 bytes instructions)
  writeU32(textOffset);  // offset
  writeU32(2);           // align: 2^2 = 4
  writeU32(0);           // reloff
  writeU32(0);           // nreloc
  writeU32(0x80000400);  // flags: S_REGULAR | S_ATTR_SOME_INSTRUCTIONS | S_ATTR_PURE_INSTRUCTIONS
  writeU32(0);           // reserved1
  writeU32(0);           // reserved2
  writeU32(0);           // reserved3

  // CMD 3: LC_SEGMENT_64 __DATA (72 bytes)
  commandCount++;
  writeU32(0x19); // LC_SEGMENT_64
  writeU32(72);
  writeStringPadded('__DATA', 16);
  writeU64(0x100000000n + BigInt(pageSize)); // vmaddr
  writeU64(pageSize);     // vmsize
  writeU64(pageSize);     // fileoff
  writeU64(pageSize);     // filesize
  writeU32(3);           // maxprot: rw
  writeU32(3);           // initprot: rw
  writeU32(0);           // nsects
  writeU32(0);           // flags

  // CMD 4: LC_SEGMENT_64 __LINKEDIT (72 bytes)
  commandCount++;
  writeU32(0x19); // LC_SEGMENT_64
  writeU32(72);
  writeStringPadded('__LINKEDIT', 16);
  writeU64(0x100000000n + BigInt(pageSize * 2)); // vmaddr
  writeU64(pageSize);     // vmsize
  writeU64(pageSize * 2); // fileoff
  writeU64(pageSize);     // filesize
  writeU32(1);           // maxprot: r--
  writeU32(1);           // initprot: r--
  writeU32(0);           // nsects
  writeU32(0);           // flags

  // CMD 5: LC_LOAD_DYLINKER (32 bytes)
  commandCount++;
  const dylinkerPath = '/usr/lib/dyld';
  const dylinkerCmdSize = 32;
  writeU32(0x0E); // LC_LOAD_DYLINKER
  writeU32(dylinkerCmdSize);
  writeU32(12); // offset to string
  writeStringPadded(dylinkerPath, 20);

  // CMD 6: LC_BUILD_VERSION (24 bytes)
  commandCount++;
  writeU32(0x32); // LC_BUILD_VERSION
  writeU32(24);
  writeU32(2); // platform: iOS
  writeU32((17 << 16) | (0 << 8)); // minos: 17.0.0
  writeU32((17 << 16) | (0 << 8)); // sdk: 17.0.0
  writeU32(0); // ntools

  // CMD 7: LC_MAIN (24 bytes)
  commandCount++;
  writeU32(0x80000028); // LC_MAIN
  writeU32(24);
  writeU64(textOffset); // entryoff
  writeU64(0);          // stacksize

  // CMD 8: LC_CODE_SIGNATURE (16 bytes)
  commandCount++;
  const csOffset = pageSize * 2; // in __LINKEDIT
  const csSize = 0x1000;
  writeU32(0x1D); // LC_CODE_SIGNATURE
  writeU32(16);
  writeU32(csOffset);
  writeU32(csSize);

  const commandsEnd = p;
  const sizeofcmds = commandsEnd - commandsStart;

  // Backpatch ncmds and sizeofcmds
  buf.writeUInt32LE(commandCount, ncmdsOffset);
  buf.writeUInt32LE(sizeofcmds, sizeofcmdsOffset);

  // Write simple arm64 instructions at textOffset:
  // mov x0, #0 (D2800000)
  // ret        (D65F03C0)
  buf.writeUInt32LE(0xD2800000, textOffset);     // mov x0, #0
  buf.writeUInt32LE(0xD65F03C0, textOffset + 4); // ret

  // SuperBlob for code signature at csOffset (minimal valid CS_SuperBlob)
  // Magic: 0xfade0cc0, length: 12 bytes, count: 0 (empty blob)
  buf.writeUInt32BE(0xFADE0CC0, csOffset);
  buf.writeUInt32BE(12, csOffset + 4);
  buf.writeUInt32BE(0, csOffset + 8);

  console.log(`Generated Mach-O arm64 binary: ${fileSize} bytes, ${commandCount} commands, sizeofcmds=${sizeofcmds}`);
  return buf;
}

const macho = createMachoBinary();
fs.writeFileSync(path.join(__dirname, 'macho_test.bin'), macho);
console.log('Successfully written macho_test.bin');
