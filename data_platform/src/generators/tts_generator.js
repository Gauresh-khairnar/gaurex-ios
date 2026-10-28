/**
 * GAUREX AI Co-Founder - High-Fidelity Multilingual TTS Generator
 */

import { randomUUID, createHash } from "node:crypto";

const TTS_VOICES = [
  { voice_id: "neo_executive_male_v1", lang: "en", gender: "M", persona: "authoritative_executive" },
  { voice_id: "neo_assistant_female_v1", lang: "en", gender: "F", persona: "friendly_concierge" },
  { voice_id: "neo_hindi_male_v1", lang: "hi", gender: "M", persona: "respectful_business" },
  { voice_id: "neo_marathi_male_v1", lang: "mr", gender: "M", persona: "pune_formal" },
  { voice_id: "neo_hinglish_female_v1", lang: "hi-en", gender: "F", persona: "agile_founder" }
];

const CLIENT_NAMES = [
  "Sharma Logistics", "Apex Infrastructure", "Zenith Tech Systems", "Maharashtra Agro",
  "Royal Heights Developers", "Kalyani Steelworks", "Tata BlueScope", "Piramal Realty"
];

export class TTSGenerator {
  generateRecord(index) {
    const voice = TTS_VOICES[index % TTS_VOICES.length];
    const client = CLIENT_NAMES[index % CLIENT_NAMES.length];
    const amount = ((index * 2430) % 950000) + 20000;
    const margin = (18.5 + (index % 15) * 0.7).toFixed(1);
    const invoiceNum = 1000 + (index % 4000);

    let text = "";
    switch (voice.lang) {
      case "en":
        text = `Good morning Gauresh. Your business has closed ₹${amount.toLocaleString("en-IN")} with a net margin of ${margin}% and invoice INV-${invoiceNum} for ${client} is ready.`;
        break;
      case "hi":
        text = `नमस्ते गौरेष। ${client} के लिए ₹${amount.toLocaleString("en-IN")} का इनवॉइस INV-${invoiceNum} तैयार है और इस सप्ताह का मुनाफा ${margin}% रहा है।`;
        break;
      case "mr":
        text = `शुभ प्रभात गौरेष सर, ${client} कडून ₹${amount.toLocaleString("en-IN")} चे इनव्हॉईस INV-${invoiceNum} तयार असून व्यवसायाचा नफा ${margin}% आहे.`;
        break;
      case "hi-en":
      default:
        text = `Hey Gauresh, ${client} ka ₹${amount.toLocaleString("en-IN")} payment clear ho gaya hai aur overall margin ${margin}% hai.`;
        break;
    }

    const words = text.split(/\s+/);
    const audioDuration = Math.round((words.length / 2.2) * 100) / 100;
    const speakingRate = 1.0 + ((index % 5) - 2) * 0.05;
    const pitchShift = ((index % 7) - 3) * 0.3;

    const phonemeRepresentation = text
      .toLowerCase()
      .replace(/[^\w\s]/g, "")
      .split(" ")
      .map(w => `/${w}/`)
      .join(" ");

    const fileId = `tts_${voice.voice_id}_${String(index + 1).padStart(6, "0")}`;
    const filePath = `audio/tts/${voice.lang}/${fileId}.flac`;
    const checksum = createHash("sha256").update(`${fileId}:${text}:${speakingRate}`).digest("hex");

    return {
      record_id: randomUUID(),
      voice_id: voice.voice_id,
      text: text,
      language: voice.lang,
      gender: voice.gender,
      persona: voice.persona,
      speaking_rate: speakingRate,
      pitch_shift: pitchShift,
      target_sample_rate: 24000,
      phoneme_transcript: phonemeRepresentation,
      audio_duration_sec: audioDuration,
      audio_file_path: filePath,
      audio_checksum_sha256: checksum,
      license: "Internal-Proprietary-GAUREX",
      created_at: new Date().toISOString()
    };
  }
}
