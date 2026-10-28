/**
 * GAUREX AI Co-Founder - 100M+ Scale & Compute Estimator
 * Mathematical modeling of storage, I/O, compression ratios, and GPU training budgets.
 */

export class ScaleEstimator {
  static getBenchmarks() {
    return {
      // Average record sizes in bytes
      avgBytesPerRecord: {
        asr_metadata: 680,
        tts_metadata: 590,
        intent: 480,
        bi_transaction: 420,
        rag_chunk: 850,
        agentic_trajectory: 1250,
        reasoning_cot: 980,
        noisy_speech: 520
      },
      // Compression factors
      compressionFactor: {
        raw_jsonl: 1.0,
        jsonl_gz: 0.22,      // ~78% compression
        parquet_snappy: 0.19 // ~81% compression
      },
      // Audio stream characteristics (per minute of speech)
      audioPerMinuteMB: {
        wav_16k_mono: 1.92,
        flac_16k_mono: 0.98,
        opus_24kbps: 0.18
      },
      // Cloud pricing estimates (USD per GB / month)
      storageRates: {
        aws_s3_standard: 0.023,
        cloudflare_r2: 0.015,
        s3_glacier_instant: 0.004
      },
      // GPU training benchmarks
      gpuRatePerHour: {
        nvidia_h100_80gb: 3.85,
        nvidia_a100_80gb: 2.20
      }
    };
  }

  static calculateProjection(recordCount) {
    const bm = this.getBenchmarks();
    const avgBytes = Object.values(bm.avgBytesPerRecord).reduce((a, b) => a + b, 0) / 8;

    const rawMetadataBytes = recordCount * avgBytes;
    const rawMetadataGB = rawMetadataBytes / (1024 ** 3);
    const parquetGB = rawMetadataGB * bm.compressionFactor.parquet_snappy;
    const jsonlGzGB = rawMetadataGB * bm.compressionFactor.jsonl_gz;

    // Speech projection (assuming 25% of the total dataset involves audio)
    const audioRecords = recordCount * 0.25;
    const avgAudioDurationSec = 4.2;
    const totalAudioHours = (audioRecords * avgAudioDurationSec) / 3600;
    const audioFlacGB = (totalAudioHours * 60 * bm.audioPerMinuteMB.flac_16k_mono) / 1024;
    const audioOpusGB = (totalAudioHours * 60 * bm.audioPerMinuteMB.opus_24kbps) / 1024;

    const totalStorageRequiredGB = parquetGB + audioFlacGB;
    const totalStorageRequiredTB = totalStorageRequiredGB / 1024;

    // Cloud storage costs per month
    const monthlyCostS3 = totalStorageRequiredGB * bm.storageRates.aws_s3_standard;
    const monthlyCostR2 = totalStorageRequiredGB * bm.storageRates.cloudflare_r2;

    // Estimated GPU training hours
    // ASR: ~0.08 GPU hrs per 100 audio hours on 8x H100
    // LLM Fine-Tuning: ~1.2 GPU hrs per 100K multi-turn conversations
    const asrGpuHoursH100 = (totalAudioHours / 100) * 0.08 * 8;
    const llmGpuHoursH100 = (recordCount / 100000) * 1.2 * 8;
    const totalGpuHoursH100 = Math.max(1, Math.round(asrGpuHoursH100 + llmGpuHoursH100));
    const estimatedTrainingCostUSD = Math.round(totalGpuHoursH100 * bm.gpuRatePerHour.nvidia_h100_80gb);

    return {
      recordCount: recordCount.toLocaleString(),
      recordCountRaw: recordCount,
      metadata: {
        rawJsonlGB: Math.round(rawMetadataGB * 100) / 100,
        parquetCompressedGB: Math.round(parquetGB * 100) / 100,
        jsonlGzGB: Math.round(jsonlGzGB * 100) / 100
      },
      audio: {
        totalHours: Math.round(totalAudioHours * 10) / 10,
        flacStorageGB: Math.round(audioFlacGB * 100) / 100,
        opusStorageGB: Math.round(audioOpusGB * 100) / 100
      },
      infrastructure: {
        totalStorageTB: Math.round(totalStorageRequiredTB * 100) / 100,
        monthlyStorageCostS3: `$${monthlyCostS3.toFixed(2)}`,
        monthlyStorageCostR2: `$${monthlyCostR2.toFixed(2)}`,
        estimatedH100GpuHours: totalGpuHoursH100,
        estimatedFineTuningCostUSD: `$${estimatedTrainingCostUSD.toLocaleString()}`
      }
    };
  }

  static getScalabilityMatrix() {
    const tiers = [1000, 100000, 1000000, 10000000, 100000000];
    return tiers.map(tier => this.calculateProjection(tier));
  }
}
