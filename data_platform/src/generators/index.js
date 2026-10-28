import { ASRGenerator } from "./asr_generator.js";
import { TTSGenerator } from "./tts_generator.js";
import { IntentGenerator } from "./intent_generator.js";
import { BIGenerator } from "./bi_generator.js";
import { RAGGenerator } from "./rag_generator.js";
import { AgenticGenerator } from "./agentic_generator.js";
import { ReasoningGenerator } from "./reasoning_generator.js";
import { NoisySpeechGenerator } from "./noisy_speech_generator.js";

export const DOMAINS = [
  "asr",
  "tts",
  "intent",
  "bi",
  "rag",
  "agentic",
  "reasoning",
  "noisy_speech"
];

export function getGenerator(domain) {
  switch (domain) {
    case "asr": return new ASRGenerator();
    case "tts": return new TTSGenerator();
    case "intent": return new IntentGenerator();
    case "bi": return new BIGenerator();
    case "rag": return new RAGGenerator();
    case "agentic": return new AgenticGenerator();
    case "reasoning": return new ReasoningGenerator();
    case "noisy_speech": return new NoisySpeechGenerator();
    default: throw new Error(`Unknown generator domain: ${domain}`);
  }
}
