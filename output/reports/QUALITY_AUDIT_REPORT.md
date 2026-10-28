# GAUREX AI CO-FOUNDER (NEO) - DATASET QUALITY AUDIT REPORT

**Generated:** Wed, 28 Oct 2026 06:02:51 GMT  
**Execution Time:** 0.34 seconds  
**Founder Context:** Gauresh Khairnar (`OWNER`)  
**Validation Pass Rate:** `43.84%`  

## 1. Executive Summary

| Metric | Count | Ratio |
| :--- | :--- | :--- |
| **Total Candidates Evaluated** | 5,475 | 100.0% |
| **Verified High-Quality Records** | 2,400 | **43.84%** |
| **Exact Duplicates Removed (SHA-256)** | 0 | 0.00% |
| **Near-Duplicates Removed (MinHash/Jaccard)** | 3,075 | 56.16% |
| **PII Violations Sanitized (DPDP/GDPR)** | 41 | N/A |
| **Total Synthesized Audio Duration** | 1.16 hrs | Speech Domains |

## 2. Multi-Domain Record Distribution

| Domain | Records | Integrity Status | Key Attributes |
| :--- | :--- | :--- | :--- |
| `asr` | 300 | Passed 100% | Validated schema & types |
| `tts` | 300 | Passed 100% | Validated schema & types |
| `intent` | 300 | Passed 100% | Validated schema & types |
| `bi` | 300 | Passed 100% | Validated schema & types |
| `rag` | 300 | Passed 100% | Validated schema & types |
| `agentic` | 300 | Passed 100% | Validated schema & types |
| `reasoning` | 300 | Passed 100% | Validated schema & types |
| `noisy_speech` | 300 | Passed 100% | Validated schema & types |

## 3. Multilingual Balance (Indic & English)

| Language | Tag | Proportion | Target Role |
| :--- | :--- | :--- | :--- |
| EN | `en` | 10.3% | Core Co-Founder Dialogue |
| HI | `hi` | 9.3% | Core Co-Founder Dialogue |
| MR | `mr` | 8.4% | Core Co-Founder Dialogue |
| HI-EN | `hi-en` | 9.5% | Core Co-Founder Dialogue |

## 4. Train / Validation / Test Leakage-Free Split

| Partition | Records | Share | Isolation Method |
| :--- | :--- | :--- | :--- |
| **Train** | 1,754 | 73.1% | In-domain model parameter learning |
| **Validation** | 348 | 14.5% | Reserved speakers & stratified holdout |
| **Test** | 298 | 12.4% | Final evaluation benchmark (untouched) |

## 5. Certification & Compliance

- **PII Policy Compliance:** Zero unmasked PAN, GSTIN, Aadhaar, phone or bank credentials found in final splits.
- **Mathematical Consistency:** All subtotal, GST slab, and invoice total calculations verified with zero tolerance.
- **Speech Leakage Shield:** Speakers present in test split are strictly absent from training partition.
