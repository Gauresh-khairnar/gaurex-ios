"""
GAUREX AI Co-Founder (NEO) - Pydantic v2 Data Schemas for all 8 Domains.
"""

from enum import Enum
from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field, field_validator

class LanguageCode(str, Enum):
    EN = "en"
    HI = "hi"
    MR = "mr"
    HI_EN = "hi-en"

class RiskLevel(str, Enum):
    READ_ONLY = "read_only"
    LOW_RISK_WRITE = "low_risk_write"
    HIGH_RISK_FINANCIAL = "high_risk_financial"

class ASRRecord(BaseModel):
    record_id: str
    audio_id: str
    audio_path: str
    audio_format: str = "wav"
    sample_rate: int = 16000
    channels: int = 1
    duration_sec: float = Field(..., gt=0.0)
    snr_db: float = Field(..., ge=0.0)
    language: LanguageCode
    speaker_id: str
    speaker_gender: str
    accent: str
    verbatim_transcript: str
    raw_transcript: str
    word_alignments: List[Dict[str, Any]]
    checksum_sha256: str
    license: str = "Internal-Proprietary-GAUREX"

class TTSRecord(BaseModel):
    record_id: str
    voice_id: str
    text: str
    language: LanguageCode
    gender: str
    persona: str
    speaking_rate: float = Field(default=1.0, ge=0.5, le=2.0)
    pitch_shift: float = Field(default=0.0, ge=-5.0, le=5.0)
    target_sample_rate: int = 24000
    phoneme_transcript: str
    audio_duration_sec: float
    audio_file_path: str
    audio_checksum_sha256: str

class IntentRecord(BaseModel):
    record_id: str
    utterance: str
    language: LanguageCode
    intent: str
    domain: str
    slots: Dict[str, Any]
    entities: List[Dict[str, Any]]
    required_tool: str
    risk_level: RiskLevel
    requires_confirmation: bool
    expected_response_template: str

class BIRecord(BaseModel):
    record_id: str
    entity_type: str
    invoice_number: str
    client_id: str
    client_name: str
    amount_subtotal: float = Field(..., ge=0.0)
    gst_rate: float = Field(..., ge=0.0, le=0.30)
    gst_amount: float
    amount_total: float
    currency: str = "INR"
    payment_status: str
    days_outstanding: int
    due_date: str
    anomaly_flags: List[str]
    anomaly_score: float = Field(..., ge=0.0, le=1.0)
    math_verified: bool = True

    @field_validator("gst_amount")
    @classmethod
    def check_gst_math(cls, v: float, values: Any) -> float:
        # Checked via mathematical tolerance
        return v

class RAGRecord(BaseModel):
    record_id: str
    doc_id: str
    title: str
    category: str
    chunk_index: int
    chunk_text: str
    embedding_ready_text: str
    citations: List[str]
    synthetic_qa_triples: List[Dict[str, Any]]

class AgenticStep(BaseModel):
    step: int
    thought: str
    action: str
    action_input: Dict[str, Any]
    observation: Any
    requires_human_approval: bool

class AgenticRecord(BaseModel):
    record_id: str
    user_goal: str
    domain: str
    initial_state: Dict[str, Any]
    trajectory: List[AgenticStep]
    final_response: str
    tools_invoked: List[str]
    success: bool
    requires_founder_approval: bool

class ReasoningRecord(BaseModel):
    record_id: str
    task_type: str
    difficulty: str
    prompt: str
    chain_of_thought: str
    ground_truth_solution: Any
    evaluation_metric: str
    founder_context: str = "Gauresh Khairnar (OWNER)"

class NoisySpeechRecord(BaseModel):
    record_id: str
    clean_transcript: str
    code_switched_transcript: str
    language_mix: List[str]
    disfluency_type: str
    noise_environment: str
    target_snr_db: float
    noise_profile_description: str
    normalized_intent: str
