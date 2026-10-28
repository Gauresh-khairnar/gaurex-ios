/**
 * GAUREX AI Co-Founder - High-Throughput Streaming Dataset Writer
 * Streams JSONL records directly to disk with bounded memory usage and auto-compression.
 */

import { createWriteStream, mkdirSync, existsSync } from "node:fs";
import { dirname } from "node:path";
import { createGzip } from "node:zlib";

export class StreamWriter {
  constructor(filePath, options = {}) {
    this.filePath = filePath;
    this.compressGzip = options.compressGzip || false;
    this.recordsWritten = 0;
    this.bytesWritten = 0;

    const dir = dirname(filePath);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }

    this.fileStream = createWriteStream(this.filePath, { flags: "w", encoding: "utf-8" });
    if (this.compressGzip) {
      this.gzip = createGzip();
      this.gzip.pipe(this.fileStream);
    }
  }

  writeRecord(record) {
    const jsonStr = JSON.stringify(record) + "\n";
    this.recordsWritten++;
    this.bytesWritten += Buffer.byteLength(jsonStr, "utf-8");

    if (this.compressGzip) {
      this.gzip.write(jsonStr);
    } else {
      this.fileStream.write(jsonStr);
    }
  }

  async close() {
    return new Promise((resolve, reject) => {
      if (this.compressGzip) {
        this.gzip.end(() => {
          this.fileStream.end(resolve);
        });
      } else {
        this.fileStream.end(resolve);
      }
    });
  }

  getStats() {
    return {
      filePath: this.filePath,
      recordsWritten: this.recordsWritten,
      bytesWritten: this.bytesWritten,
      approxSizeMB: Math.round((this.bytesWritten / (1024 * 1024)) * 100) / 100
    };
  }
}
