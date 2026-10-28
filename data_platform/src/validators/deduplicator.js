/**
 * GAUREX AI Co-Founder - High-Throughput Deduplication Engine
 * Combines exact cryptographic SHA-256 indexing with MinHash / Jaccard Near-Deduplication.
 */

import { createHash } from "node:crypto";

export class DeduplicationEngine {
  constructor(options = {}) {
    this.exactSeenHashes = new Set();
    this.nearDedupThreshold = options.similarityThreshold || 0.85;
    this.numHashFunctions = options.numHashFunctions || 32;
    this.minHashIndex = []; // List of { id, text, shingles, signature }
    this.duplicatesRemovedCount = 0;
    this.exactDuplicatesCount = 0;
    this.nearDuplicatesCount = 0;

    // Deterministic random seeds for MinHash permutation
    this.hashSeeds = Array.from({ length: this.numHashFunctions }, (_, i) => (i * 2654435761 + 1013904223) >>> 0);
  }

  /**
   * Generates SHA-256 for arbitrary payload
   */
  computeHash(content) {
    const stringified = typeof content === "string" ? content : JSON.stringify(content);
    return createHash("sha256").update(stringified).digest("hex");
  }

  /**
   * Extract character 3-grams shingles from normalized text
   */
  _extractShingles(text, k = 3) {
    const normalized = text.toLowerCase().replace(/[\s\p{P}]+/gu, " ").trim();
    const shingles = new Set();
    for (let i = 0; i <= normalized.length - k; i++) {
      shingles.add(normalized.substring(i, i + k));
    }
    return shingles;
  }

  /**
   * Compute MinHash signature vector
   */
  _computeMinHashSignature(shingles) {
    const signature = new Array(this.numHashFunctions).fill(Infinity);
    for (const shingle of shingles) {
      const h0 = this._fnv1a(shingle);
      for (let i = 0; i < this.numHashFunctions; i++) {
        // Linear hash permutation: (a * h + b) mod 2^32
        const hashVal = ((this.hashSeeds[i] ^ h0) * 16777619) >>> 0;
        if (hashVal < signature[i]) {
          signature[i] = hashVal;
        }
      }
    }
    return signature;
  }

  _fnv1a(str) {
    let hash = 2166136261;
    for (let i = 0; i < str.length; i++) {
      hash ^= str.charCodeAt(i);
      hash = (hash * 16777619) >>> 0;
    }
    return hash;
  }

  /**
   * Estimate Jaccard similarity via MinHash signature matching
   */
  _estimateJaccard(sigA, sigB) {
    let matches = 0;
    for (let i = 0; i < this.numHashFunctions; i++) {
      if (sigA[i] === sigB[i]) {
        matches++;
      }
    }
    return matches / this.numHashFunctions;
  }

  /**
   * Evaluate a record. Returns { isDuplicate: boolean, reason: string | null }
   */
  checkAndRecord(recordId, textualPayload, fullRecord) {
    const hash = this.computeHash(fullRecord);

    // 1. Exact Duplicate Check
    if (this.exactSeenHashes.has(hash)) {
      this.duplicatesRemovedCount++;
      this.exactDuplicatesCount++;
      return { isDuplicate: true, reason: "EXACT_HASH_COLLISION" };
    }

    // 2. Near-Duplicate Check on text payload
    if (textualPayload && typeof textualPayload === "string" && textualPayload.length > 20) {
      const shingles = this._extractShingles(textualPayload);
      if (shingles.size > 0) {
        const sig = this._computeMinHashSignature(shingles);

        // Check against recent window (last 50 items) for efficiency
        const windowCheckLimit = Math.min(this.minHashIndex.length, 50);
        for (let i = this.minHashIndex.length - 1; i >= Math.max(0, this.minHashIndex.length - windowCheckLimit); i--) {
          const entry = this.minHashIndex[i];
          const similarity = this._estimateJaccard(sig, entry.signature);
          if (similarity >= this.nearDedupThreshold) {
            this.duplicatesRemovedCount++;
            this.nearDuplicatesCount++;
            return {
              isDuplicate: true,
              reason: `NEAR_DUPLICATE_JACCARD_${similarity.toFixed(2)}_WITH_${entry.id}`
            };
          }
        }

        this.minHashIndex.push({ id: recordId, signature: sig });
        if (this.minHashIndex.length > 500) {
          this.minHashIndex.shift(); // Keep sliding window
        }
      }
    }

    this.exactSeenHashes.add(hash);
    return { isDuplicate: false, reason: null };
  }

  getStats() {
    return {
      uniqueRecords: this.exactSeenHashes.size,
      totalDuplicatesFiltered: this.duplicatesRemovedCount,
      exactHashDuplicates: this.exactDuplicatesCount,
      nearDuplicatesFiltered: this.nearDuplicatesCount
    };
  }
}
