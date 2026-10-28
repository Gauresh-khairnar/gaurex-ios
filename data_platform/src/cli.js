#!/usr/bin/env node

/**
 * GAUREX AI Co-Founder - Unified Dataset Engineering CLI
 */

import { resolve, join } from "node:path";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { DOMAINS, getGenerator } from "./generators/index.js";
import { PIISanitizer } from "./validators/pii_sanitizer.js";
import { DeduplicationEngine } from "./validators/deduplicator.js";
import { SchemaGuard } from "./validators/schema_guard.js";
import { DatasetSplitter } from "./pipeline/splitter.js";
import { StreamWriter } from "./pipeline/stream_writer.js";
import { ScaleEstimator } from "./estimators/scale_estimator.js";
import { QualityReporter } from "./reporting/quality_report.js";

const DEFAULT_OUTPUT_DIR = resolve("output");

function parseArgs(args) {
  const options = {
    command: args[0] || "run-all",
    count: 2400, // 300 per domain across 8 domains
    outputDir: DEFAULT_OUTPUT_DIR,
    domains: DOMAINS
  };

  for (let i = 1; i < args.length; i++) {
    if (args[i] === "--count" && args[i + 1]) {
      options.count = parseInt(args[i + 1], 10);
      i++;
    } else if (args[i] === "--output" && args[i + 1]) {
      options.outputDir = resolve(args[i + 1]);
      i++;
    } else if (args[i] === "--scale" && args[i + 1]) {
      options.scale = parseInt(args[i + 1], 10);
      i++;
    }
  }

  return options;
}

async function runPipeline(options) {
  const startTime = Date.now();
  console.log(`\n======================================================`);
  console.log(`🚀 GAUREX AI CO-FOUNDER (NEO) - DATASET PIPELINE`);
  console.log(`Target Count: ${options.count.toLocaleString()} verified records across ${options.domains.length} domains`);
  console.log(`Founder Context: Gauresh Khairnar (OWNER)`);
  console.log(`======================================================\n`);

  const piiSanitizer = new PIISanitizer();
  const deduplicator = new DeduplicationEngine({ similarityThreshold: 0.94 });
  const splitter = new DatasetSplitter();

  const domainBreakdown = {};
  const languageDistribution = { en: 0, hi: 0, mr: 0, "hi-en": 0 };
  const splitStats = { train: 0, val: 0, test: 0 };
  let totalAudioDurationSec = 0;
  let totalCandidatesEvaluated = 0;
  let validRecordsCount = 0;

  // Prepare split stream writers
  const splitWriters = {
    train: new StreamWriter(join(options.outputDir, "splits", "train", "dataset_train.jsonl")),
    val: new StreamWriter(join(options.outputDir, "splits", "val", "dataset_val.jsonl")),
    test: new StreamWriter(join(options.outputDir, "splits", "test", "dataset_test.jsonl"))
  };

  // Dedicated domain stream writers
  const domainWriters = {};
  for (const domain of options.domains) {
    domainWriters[domain] = new StreamWriter(
      join(options.outputDir, "processed", domain, `${domain}_verified.jsonl`)
    );
    domainBreakdown[domain] = 0;
  }

  const perDomainTarget = Math.max(1, Math.floor(options.count / options.domains.length));

  for (const domain of options.domains) {
    process.stdout.write(`⏳ Generating & verifying domain: ${domain.padEnd(14)} `);
    const generator = getGenerator(domain);
    let domainSuccess = 0;
    let candidateIndex = 0;
    const maxAttempts = perDomainTarget * 10;

    while (domainSuccess < perDomainTarget && candidateIndex < maxAttempts) {
      totalCandidatesEvaluated++;
      candidateIndex++;

      // 1. Generate candidate record
      const rawRecord = generator.generateRecord(candidateIndex);

      // 2. Validate strict schema and mathematical constraints
      const schemaCheck = SchemaGuard.validate(domain, rawRecord);
      if (!schemaCheck.valid) {
        console.warn(`[Schema Failure] ${domain}:`, schemaCheck.errors);
        continue;
      }

      // 3. Redact & sanitize sensitive PII
      const sanitizedRecord = piiSanitizer.sanitize(rawRecord);

      // 4. Exact & Near Deduplication check
      let textToShingle = "";
      if (domain === "agentic") {
        textToShingle = `${sanitizedRecord.user_goal} ${JSON.stringify(sanitizedRecord.trajectory)}`;
      } else if (domain === "reasoning") {
        textToShingle = `${sanitizedRecord.prompt} ${sanitizedRecord.chain_of_thought}`;
      } else if (domain === "bi") {
        textToShingle = `${sanitizedRecord.invoice_number} ${sanitizedRecord.client_name} ${sanitizedRecord.amount_total}`;
      } else {
        textToShingle = sanitizedRecord.utterance ||
          sanitizedRecord.verbatim_transcript ||
          sanitizedRecord.text ||
          sanitizedRecord.chunk_text ||
          sanitizedRecord.prompt ||
          sanitizedRecord.code_switched_transcript ||
          "";
      }

      const dedupCheck = deduplicator.checkAndRecord(sanitizedRecord.record_id, textToShingle, sanitizedRecord);
      if (dedupCheck.isDuplicate) {
        continue; // Filtered duplicate
      }

      // 5. Assign to Leakage-Free Split
      const splitPartition = splitter.assignSplit(sanitizedRecord, domain);
      sanitizedRecord._split = splitPartition;
      sanitizedRecord._domain = domain;

      // 6. Stream record to disk
      domainWriters[domain].writeRecord(sanitizedRecord);
      splitWriters[splitPartition].writeRecord(sanitizedRecord);

      // 7. Track stats
      domainSuccess++;
      validRecordsCount++;
      domainBreakdown[domain]++;
      splitStats[splitPartition]++;

      if (sanitizedRecord.language) {
        languageDistribution[sanitizedRecord.language] = (languageDistribution[sanitizedRecord.language] || 0) + 1;
      }
      if (sanitizedRecord.duration_sec) {
        totalAudioDurationSec += sanitizedRecord.duration_sec;
      } else if (sanitizedRecord.audio_duration_sec) {
        totalAudioDurationSec += sanitizedRecord.audio_duration_sec;
      }
    }
    console.log(`[OK] (${domainSuccess} records)`);
  }

  // Close all streaming file handles
  for (const w of Object.values(domainWriters)) await w.close();
  for (const w of Object.values(splitWriters)) await w.close();

  const dedupStats = deduplicator.getStats();
  const piiStats = piiSanitizer.getAuditStats();
  const durationMs = Date.now() - startTime;

  // Generate Quality Audit Report
  const reportPath = join(options.outputDir, "reports", "QUALITY_AUDIT_REPORT.md");
  QualityReporter.generateReport({
    totalGenerated: totalCandidatesEvaluated,
    validRecords: validRecordsCount,
    duplicatesFiltered: dedupStats.totalDuplicatesFiltered,
    exactHashCollisions: dedupStats.exactHashDuplicates,
    nearDuplicatesFiltered: dedupStats.nearDuplicatesFiltered,
    piiViolationsRedacted: piiStats.totalViolationsPrevented,
    domainBreakdown,
    languageDistribution,
    splitStats,
    audioDurationHours: totalAudioDurationSec / 3600,
    executionTimeMs: durationMs
  }, reportPath);

  // Generate manifest JSON
  const manifestPath = join(options.outputDir, "manifest.json");
  writeFileSync(manifestPath, JSON.stringify({
    pipelineVersion: "1.0.0",
    generatedAt: new Date().toISOString(),
    owner: "Gauresh Khairnar (OWNER)",
    recordsVerified: validRecordsCount,
    splitStats,
    domainBreakdown,
    reportPath
  }, null, 2), "utf-8");

  console.log(`\n======================================================`);
  console.log(`✅ PIPELINE EXECUTION COMPLETE`);
  console.log(`Total Records Written: ${validRecordsCount.toLocaleString()}`);
  console.log(`Train / Val / Test:    ${splitStats.train} / ${splitStats.val} / ${splitStats.test}`);
  console.log(`Quality Report:        ${reportPath}`);
  console.log(`Manifest File:         ${manifestPath}`);
  console.log(`======================================================\n`);
}

function runEstimate(scale) {
  console.log(`\n======================================================`);
  console.log(`📊 GAUREX AI CO-FOUNDER - 100M+ SCALE ESTIMATOR`);
  console.log(`======================================================\n`);

  if (scale) {
    const projection = ScaleEstimator.calculateProjection(scale);
    console.log(JSON.stringify(projection, null, 2));
    return;
  }

  const matrix = ScaleEstimator.getScalabilityMatrix();
  console.table(matrix.map(m => ({
    "Records Target": m.recordCount,
    "Metadata Parquet (GB)": m.metadata.parquetCompressedGB,
    "Speech Audio (Hrs)": m.audio.totalHours,
    "Speech FLAC (GB)": m.audio.flacStorageGB,
    "Total TB": m.infrastructure.totalStorageTB,
    "S3 Cost/Mo": m.infrastructure.monthlyStorageCostS3,
    "R2 Cost/Mo": m.infrastructure.monthlyStorageCostR2,
    "H100 GPU Hrs": m.infrastructure.estimatedH100GpuHours,
    "Train Cost": m.infrastructure.estimatedFineTuningCostUSD
  })));
}

async function main() {
  const options = parseArgs(process.argv.slice(2));

  switch (options.command) {
    case "estimate":
      runEstimate(options.scale);
      break;
    case "run-all":
    case "generate":
      await runPipeline(options);
      break;
    default:
      console.log(`Usage: node src/cli.js [run-all | estimate | generate] [--count <N>] [--scale <N>]`);
  }
}

main().catch(err => {
  console.error("Pipeline failure:", err);
  process.exit(1);
});
