/**
 * GAUREX AI Co-Founder - Resumable Pipeline Checkpoint Manager
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";

export class CheckpointManager {
  constructor(checkpointPath) {
    this.path = checkpointPath;
    const dir = dirname(checkpointPath);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }
  }

  load() {
    if (existsSync(this.path)) {
      try {
        const raw = readFileSync(this.path, "utf-8");
        return JSON.parse(raw);
      } catch (e) {
        console.warn(`[Checkpoint] Corrupted state at ${this.path}, resetting.`, e.message);
      }
    }
    return {
      lastBatchIndex: 0,
      totalRecordsProcessed: 0,
      domainProgress: {},
      lastUpdated: new Date().toISOString()
    };
  }

  save(state) {
    state.lastUpdated = new Date().toISOString();
    writeFileSync(this.path, JSON.stringify(state, null, 2), "utf-8");
  }
}
