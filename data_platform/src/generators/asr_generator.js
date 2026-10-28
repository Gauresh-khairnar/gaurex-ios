/**
 * GAUREX AI Co-Founder - Multilingual ASR Dataset Generator
 * Languages: English (en), Hindi (hi), Marathi (mr), Hinglish (hi-en)
 */

import { randomUUID, createHash } from "node:crypto";

const SPEAKERS = [
  { id: "spk_gauresh_01", gender: "M", accent: "indian_english_executive", lang: "en" },
  { id: "spk_rajesh_02", gender: "M", accent: "mumbai_hinglish", lang: "hi-en" },
  { id: "spk_sneha_03", gender: "F", accent: "pune_marathi", lang: "mr" },
  { id: "spk_amit_04", gender: "M", accent: "delhi_hindi", lang: "hi" },
  { id: "spk_priya_05", gender: "F", accent: "indian_english_standard", lang: "en" },
  { id: "spk_tanvi_06", gender: "F", accent: "marathwada_marathi", lang: "mr" },
  { id: "spk_vikram_07", gender: "M", accent: "bilingual_marathi_hinglish", lang: "hi-en" },
  { id: "spk_ananya_08", gender: "F", accent: "mumbai_business_hindi", lang: "hi" }
];

const CLIENT_NAMES = [
  "Sharma Logistics", "Apex Infrastructure", "Zenith Tech Systems", "Maharashtra Agro",
  "Royal Heights Developers", "Kalyani Steelworks", "Godrej Properties Pune", "Tata BlueScope",
  "Piramal Realty", "L&T Construction", "Shree Cement Depot", "Venkatesh Transporters",
  "Kirloskar Pneumatic", "Mahindra Heavy Logistics", "Bajaj Auto Vendors"
];

const CITIES = ["Mumbai", "Pune", "Nashik", "Nagpur", "Thane", "Aurangabad", "Kolhapur", "Bengaluru", "Ahmedabad"];

export class ASRGenerator {
  generateRecord(index) {
    const speaker = SPEAKERS[index % SPEAKERS.length];
    const client = CLIENT_NAMES[index % CLIENT_NAMES.length];
    const city = CITIES[index % CITIES.length];
    const amount = ((index * 1370) % 850000) + 15000;
    const invNum = 2000 + (index % 5000);
    const days = (index % 60) + 1;

    let rawText = "";

    switch (speaker.lang) {
      case "en": {
        const enVariants = [
          `Good morning NEO, display today's revenue breakdown across our ${city} projects.`,
          `Generate a tax invoice for ${client} amounting to ₹${amount.toLocaleString("en-IN")} with 18% GST.`,
          `What is the outstanding balance for ${client} over the last ${days} days?`,
          `Check invoice number INV-${invNum} for ${client} in ${city} and verify status.`,
          `Draft an urgent payment reminder to ${client} for ₹${amount.toLocaleString("en-IN")}.`,
          `Schedule a site compliance inspection in ${city} for Friday morning with Gauresh.`
        ];
        rawText = enVariants[index % enVariants.length];
        break;
      }
      case "hi": {
        const hiVariants = [
          `नमस्ते नियो, ${city} प्रोजेक्ट का कुल टर्नओवर और पेंडिंग इनवॉइस दिखाओ।`,
          `${client} के लिए ₹${amount.toLocaleString("en-IN")} का नया बिल 18 प्रतिशत जीएसटी के साथ तैयार करो।`,
          `${client} का पिछले ${days} दिनों का बकाया पेमेंट कितना है?`,
          `इनवॉइस नंबर ${invNum} का पेमेंट स्टेटस क्या है?`,
          `आज हमारे ${city} वाले बैंक अकाउंट में कितना कैश फ्लो डिपॉजिट हुआ है?`,
          `${client} को ₹${amount.toLocaleString("en-IN")} के बकाया पेमेंट का रिमाइंडर भेजो।`
        ];
        rawText = hiVariants[index % hiVariants.length];
        break;
      }
      case "mr": {
        const mrVariants = [
          `शुभ प्रभात नियो, ${city} विभागातील सर्व चालू कामांचा आर्थिक हिशोब दाखवा.`,
          `${client} साठी ₹${amount.toLocaleString("en-IN")} चे नवीन जीएसटी इनव्हॉईस तयार करा.`,
          `${client} कडून गेल्या ${days} दिवसांपासून येणे बाकी रक्कम किती आहे?`,
          `बिल क्रमांक ${invNum} चे पैसे जमा झाले आहेत का ते तपासा.`,
          `${city} साईटवरील कामगारांच्या हजेरीचा अहवाल स्क्रीनवर दाखवा.`,
          `${client} यांना तात्काळ ₹${amount.toLocaleString("en-IN")} च्या बिलाची आठवण पाठवा.`
        ];
        rawText = mrVariants[index % mrVariants.length];
        break;
      }
      case "hi-en":
      default: {
        const hienVariants = [
          `Hey NEO, ${client} ka ₹${amount.toLocaleString("en-IN")} ka pending balance clear hua kya?`,
          `${city} branch ke liye invoice number INV-${invNum} regenerate karo with 18% GST.`,
          `${client} ko payment reminder WhatsApp draft kar do, unka payment ${days} din se pending hai.`,
          `Aaj total collection kitna hua hai aur ${city} site ka expense kitna hai?`,
          `New client ${client} register karo ${city} location ke liye immediately.`,
          `Worker payroll confirm karo ₹${amount.toLocaleString("en-IN")} for this week.`
        ];
        rawText = hienVariants[index % hienVariants.length];
        break;
      }
    }

    const words = rawText.split(/\s+/);
    const duration = Math.max(1.8, Math.round((words.length / 2.3) * 100) / 100);
    const snr = Math.round((18.0 + (index % 17) * 0.9) * 10) / 10;

    let currentOffset = 0.15;
    const wordAlignments = words.map((word) => {
      const wordDuration = Math.round(((duration - 0.3) / words.length) * 100) / 100;
      const start = Math.round(currentOffset * 100) / 100;
      const end = Math.round((start + wordDuration) * 100) / 100;
      currentOffset = end + 0.04;
      return {
        word,
        start_sec: start,
        end_sec: end,
        confidence: 0.95 + (index % 5) * 0.01
      };
    });

    const audioId = `audio_asr_${speaker.lang}_${String(index + 1).padStart(6, "0")}`;
    const audioPath = `audio/asr/${speaker.lang}/${audioId}.wav`;
    const checksum = createHash("sha256").update(`${audioId}:${rawText}:${duration}`).digest("hex");

    return {
      record_id: randomUUID(),
      audio_id: audioId,
      audio_path: audioPath,
      audio_format: "wav",
      sample_rate: 16000,
      channels: 1,
      duration_sec: duration,
      snr_db: snr,
      language: speaker.lang,
      speaker_id: speaker.id,
      speaker_gender: speaker.gender,
      accent: speaker.accent,
      verbatim_transcript: rawText,
      raw_transcript: rawText,
      word_alignments: wordAlignments,
      checksum_sha256: checksum,
      license: "Internal-Proprietary-GAUREX",
      created_at: new Date().toISOString()
    };
  }
}
