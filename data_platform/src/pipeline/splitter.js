/**
 * GAUREX AI Co-Founder - Leakage-Free Dataset Splitter
 * Enforces speaker-isolation on speech data and deterministic stratified splitting on tabular/text data.
 * Ratios: 80% Train, 10% Validation, 10% Test.
 */

import { createHash } from "node:crypto";

export class DatasetSplitter {
  constructor(options = {}) {
    this.trainRatio = options.trainRatio || 0.80;
    this.valRatio = options.valRatio || 0.10;
    this.testRatio = options.testRatio || 0.10;

    // Reserve specific speakers exclusively for Val/Test to prevent speech leakage
    this.reservedSpeakers = {
      val: new Set(["spk_priya_05", "spk_tanvi_06", "neo_marathi_male_v1"]),
      test: new Set(["spk_vikram_07", "spk_ananya_08", "neo_hinglish_female_v1"])
    };
  }

  /**
   * Assigns a record to "train", "val", or "test"
   */
  assignSplit(record, domain) {
    // 1. Speaker-isolated split for speech domains
    if ((domain === "asr" || domain === "tts") && record.speaker_id) {
      if (this.reservedSpeakers.test.has(record.speaker_id)) return "test";
      if (this.reservedSpeakers.val.has(record.speaker_id)) return "val";
      return "train";
    }

    if (domain === "tts" && record.voice_id) {
      if (this.reservedSpeakers.test.has(record.voice_id)) return "test";
      if (this.reservedSpeakers.val.has(record.voice_id)) return "val";
      return "train";
    }

    // 2. Deterministic hash-based split for all other domains
    const hash = createHash("md5").update(record.record_id || "").digest("hex");
    const bucket = parseInt(hash.substring(0, 4), 16) % 100; // 0 to 99

    if (bucket < this.trainRatio * 100) {
      return "train";
    } else if (bucket < (this.trainRatio + this.valRatio) * 100) {
      return "val";
    } else {
      return "test";
    }
  }
}
