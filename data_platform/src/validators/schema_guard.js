/**
 * GAUREX AI Co-Founder - Schema Guard and Mathematical Consistency Validator
 */

const VALID_LANGUAGES = new Set(["en", "hi", "mr", "hi-en"]);
const VALID_RISK_LEVELS = new Set(["read_only", "low_risk_write", "high_risk_financial"]);
const VALID_DOMAINS = new Set(["finance", "crm", "workforce", "analytics", "operations", "system"]);

export class SchemaGuard {
  static validateASR(record) {
    const errors = [];
    if (!record.record_id) errors.push("Missing record_id");
    if (!record.audio_id) errors.push("Missing audio_id");
    if (!VALID_LANGUAGES.has(record.language)) errors.push(`Invalid language: ${record.language}`);
    if (typeof record.duration_sec !== "number" || record.duration_sec <= 0) errors.push("duration_sec must be > 0");
    if (typeof record.snr_db !== "number" || record.snr_db < 0) errors.push("snr_db must be positive");
    if (!record.verbatim_transcript || typeof record.verbatim_transcript !== "string") errors.push("Missing verbatim_transcript");
    if (!record.checksum_sha256 || record.checksum_sha256.length !== 64) errors.push("Invalid checksum_sha256");
    return { valid: errors.length === 0, errors };
  }

  static validateTTS(record) {
    const errors = [];
    if (!record.record_id) errors.push("Missing record_id");
    if (!record.text || typeof record.text !== "string") errors.push("Missing text");
    if (!VALID_LANGUAGES.has(record.language)) errors.push(`Invalid language: ${record.language}`);
    if (!record.voice_id) errors.push("Missing voice_id");
    if (typeof record.speaking_rate !== "number" || record.speaking_rate < 0.5 || record.speaking_rate > 2.0) {
      errors.push("speaking_rate must be between 0.5 and 2.0");
    }
    if (!record.phoneme_transcript) errors.push("Missing phoneme_transcript");
    return { valid: errors.length === 0, errors };
  }

  static validateIntent(record) {
    const errors = [];
    if (!record.record_id) errors.push("Missing record_id");
    if (!record.utterance) errors.push("Missing utterance");
    if (!VALID_LANGUAGES.has(record.language)) errors.push(`Invalid language: ${record.language}`);
    if (!record.intent || !record.intent.includes(".")) errors.push("Intent must follow domain.action syntax");
    if (!VALID_RISK_LEVELS.has(record.risk_level)) errors.push(`Invalid risk_level: ${record.risk_level}`);
    if (!record.required_tool) errors.push("Missing required_tool");
    return { valid: errors.length === 0, errors };
  }

  static validateBI(record) {
    const errors = [];
    if (!record.record_id) errors.push("Missing record_id");
    if (typeof record.amount_subtotal !== "number" || record.amount_subtotal < 0) errors.push("amount_subtotal must be >= 0");
    if (typeof record.gst_rate !== "number" || record.gst_rate < 0 || record.gst_rate > 0.30) errors.push("gst_rate must be valid (0 to 0.30)");

    // Strict mathematical consistency check
    const expectedGst = Math.round(record.amount_subtotal * record.gst_rate * 100) / 100;
    const diffGst = Math.abs(expectedGst - record.gst_amount);
    if (diffGst > 0.05) {
      errors.push(`GST mathematical inconsistency: expected ${expectedGst}, found ${record.gst_amount}`);
    }

    const expectedTotal = Math.round((record.amount_subtotal + record.gst_amount) * 100) / 100;
    const diffTotal = Math.abs(expectedTotal - record.amount_total);
    if (diffTotal > 0.05) {
      errors.push(`Total mathematical inconsistency: expected ${expectedTotal}, found ${record.amount_total}`);
    }

    return { valid: errors.length === 0, errors };
  }

  static validateRAG(record) {
    const errors = [];
    if (!record.record_id) errors.push("Missing record_id");
    if (!record.doc_id) errors.push("Missing doc_id");
    if (!record.chunk_text || record.chunk_text.length < 50) errors.push("chunk_text too short (< 50 chars)");
    if (!Array.isArray(record.synthetic_qa_triples) || record.synthetic_qa_triples.length === 0) {
      errors.push("Missing synthetic_qa_triples");
    }
    return { valid: errors.length === 0, errors };
  }

  static validateAgentic(record) {
    const errors = [];
    if (!record.record_id) errors.push("Missing record_id");
    if (!record.user_goal) errors.push("Missing user_goal");
    if (!Array.isArray(record.trajectory) || record.trajectory.length === 0) errors.push("Empty trajectory steps");
    for (const step of record.trajectory || []) {
      if (!step.thought || !step.action) {
        errors.push("Step missing thought or action");
        break;
      }
    }
    return { valid: errors.length === 0, errors };
  }

  static validateReasoning(record) {
    const errors = [];
    if (!record.record_id) errors.push("Missing record_id");
    if (!record.prompt) errors.push("Missing prompt");
    if (!record.chain_of_thought) errors.push("Missing chain_of_thought");
    if (record.ground_truth_solution === undefined || record.ground_truth_solution === null) {
      errors.push("Missing ground_truth_solution");
    }
    return { valid: errors.length === 0, errors };
  }

  static validateNoisySpeech(record) {
    const errors = [];
    if (!record.record_id) errors.push("Missing record_id");
    if (!record.clean_transcript) errors.push("Missing clean_transcript");
    if (!record.code_switched_transcript) errors.push("Missing code_switched_transcript");
    if (!record.noise_environment) errors.push("Missing noise_environment");
    return { valid: errors.length === 0, errors };
  }

  static validate(domain, record) {
    switch (domain) {
      case "asr": return this.validateASR(record);
      case "tts": return this.validateTTS(record);
      case "intent": return this.validateIntent(record);
      case "bi": return this.validateBI(record);
      case "rag": return this.validateRAG(record);
      case "agentic": return this.validateAgentic(record);
      case "reasoning": return this.validateReasoning(record);
      case "noisy_speech": return this.validateNoisySpeech(record);
      default: return { valid: false, errors: [`Unknown domain: ${domain}`] };
    }
  }
}
