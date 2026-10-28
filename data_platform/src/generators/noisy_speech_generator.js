/**
 * GAUREX AI Co-Founder - Multilingual Code-Switching & Acoustic Degradation Generator
 */

import { randomUUID } from "node:crypto";

const CLIENTS = [
  "Sharma Logistics", "Apex Infrastructure", "Zenith Tech Systems", "Maharashtra Agro",
  "Royal Heights Developers", "Kalyani Steelworks", "Tata BlueScope", "Piramal Realty"
];

const NOISE_PROFILES = [
  { environment: "street_traffic", snr_db: 8.5, description: "Honking, urban vehicular rumble, pedestrian noise" },
  { environment: "construction_site", snr_db: 6.0, description: "Concrete mixer, drilling, reverberant open structure" },
  { environment: "office_ambient", snr_db: 22.0, description: "Keyboard typing, HVAC hum, background chatter" },
  { environment: "cellular_low_bitrate", snr_db: 14.0, description: "8kHz AMR-NB codec compression artifacts with jitter" },
  { environment: "reverberant_warehouse", snr_db: 12.0, description: "High reverberation time (RT60 ~ 1.4s) and metal roof echo" }
];

export class NoisySpeechGenerator {
  generateRecord(index) {
    const client = CLIENTS[index % CLIENTS.length];
    const noise = NOISE_PROFILES[index % NOISE_PROFILES.length];
    const amount = ((index * 3820) % 800000) + 18000;
    const invNum = 1000 + (index % 4000);

    const patterns = [
      {
        clean: `Create an invoice for ${client} for ₹${amount.toLocaleString("en-IN")}.`,
        code_switched: `Arre NEO, ${client} sathi ₹${amount.toLocaleString("en-IN")} cha tax invoice banva na please.`,
        mix: ["mr", "en"],
        disfluency: "hesitation_arre"
      },
      {
        clean: `Show all pending client payments for invoice ${invNum}.`,
        code_switched: `Umm suno, ${client} ka invoice ${invNum} ka pending amount kitna hai screen pe show karo.`,
        mix: ["hi", "en"],
        disfluency: "filler_umm"
      },
      {
        clean: `Approve worker overtime for the late shift at site.`,
        code_switched: `Kal raat ka overtime shift check karke na... approve kar dijiye system me.`,
        mix: ["hi", "en"],
        disfluency: "pause_hesitation"
      },
      {
        clean: `Export quarterly GST summary for ${client}.`,
        code_switched: `${client} cha Q${(index % 4) + 1} GST report... I mean GSTR-1 summary export kara.`,
        mix: ["mr", "en"],
        disfluency: "self_correction"
      }
    ];

    const item = patterns[index % patterns.length];

    return {
      record_id: randomUUID(),
      clean_transcript: item.clean,
      code_switched_transcript: item.code_switched,
      language_mix: item.mix,
      disfluency_type: item.disfluency,
      noise_environment: noise.environment,
      target_snr_db: noise.snr_db,
      noise_profile_description: noise.description,
      normalized_intent: "system.multilingual_robustness_test",
      created_at: new Date().toISOString()
    };
  }
}
