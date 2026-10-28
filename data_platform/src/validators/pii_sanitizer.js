/**
 * GAUREX AI Co-Founder - High-Fidelity PII Redaction Engine
 * Compliant with ISO/IEC 27001, Indian Digital Personal Data Protection Act (DPDP), and GDPR.
 */

const PII_PATTERNS = {
  pan: {
    regex: /\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b/g,
    placeholder: "[REDACTED_PAN]"
  },
  aadhaar: {
    regex: /\b\d{4}\s?\d{4}\s?\d{4}\b/g,
    placeholder: "[REDACTED_AADHAAR]"
  },
  gstin: {
    regex: /\b\d{2}[A-Z]{5}\d{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}\b/g,
    placeholder: "[REDACTED_GSTIN]"
  },
  phone_in: {
    regex: /(?:(?:\+91|91|0)[\s-]?)?[6-9]\d{4}[\s-]?\d{5}\b/g,
    placeholder: "[REDACTED_PHONE]"
  },
  card: {
    regex: /\b(?:\d{4}[-\s]?){3}\d{4}\b/g,
    placeholder: "[REDACTED_CARD]"
  },
  email: {
    regex: /\b[A-Za-z0-9._%+-]+@(?!gaurex\.internal|client-synth\.test)[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g,
    placeholder: "[REDACTED_EMAIL]"
  }
};

export class PIISanitizer {
  constructor() {
    this.auditLog = [];
  }

  /**
   * Deeply cleans an object or text string of sensitive PII data.
   */
  sanitize(input) {
    if (typeof input === "string") {
      return this._sanitizeString(input);
    }
    if (Array.isArray(input)) {
      return input.map(item => this.sanitize(item));
    }
    if (input !== null && typeof input === "object") {
      const sanitizedObj = {};
      for (const [key, value] of Object.entries(input)) {
        sanitizedObj[key] = this.sanitize(value);
      }
      return sanitizedObj;
    }
    return input;
  }

  _sanitizeString(str) {
    let clean = str;
    const detected = [];

    for (const [type, rule] of Object.entries(PII_PATTERNS)) {
      if (rule.regex.test(clean)) {
        detected.push(type);
        clean = clean.replace(rule.regex, rule.placeholder);
      }
    }

    if (detected.length > 0) {
      this.auditLog.push({
        timestamp: new Date().toISOString(),
        types: detected
      });
    }

    return clean;
  }

  getAuditStats() {
    const summary = {};
    for (const entry of this.auditLog) {
      for (const type of entry.types) {
        summary[type] = (summary[type] || 0) + 1;
      }
    }
    return {
      totalViolationsPrevented: this.auditLog.length,
      breakdown: summary
    };
  }
}
