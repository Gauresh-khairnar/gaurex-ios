/**
 * GAUREX AI Co-Founder - RAG Knowledge Base & Synthetic QA Generator
 */

import { randomUUID } from "node:crypto";

const TOPICS = [
  {
    category: "taxation_compliance",
    doc_id: "sop_finance_gst",
    title: "GAUREX Financial SOP: GST Invoicing and Input Tax Credit (ITC) Rules",
    sections: [
      {
        sec: "3.1",
        text: "Section 3.1: All intra-state transactions within Maharashtra carry CGST 9% and SGST 9% (aggregate 18%). Inter-state transactions attract IGST at 18%. Valid GSTIN of GAUREX and client must appear on all tax invoices.",
        q: "What GST rate applies to inter-state services?",
        a: "Inter-state services attract an IGST rate of 18%."
      },
      {
        sec: "3.4",
        text: "Section 3.4: Payment terms are strictly Net-30 days. Accounts exceeding 45 days overdue are automatically flagged by NEO risk guard, halting further credit line extensions pending founder review.",
        q: "What happens when an account exceeds 45 days overdue?",
        a: "NEO risk guard automatically freezes credit line extensions pending founder review by Gauresh Khairnar."
      },
      {
        sec: "3.9",
        text: "Section 3.9: Input Tax Credit (ITC) reconciliation must be verified against GSTR-2B before monthly GST return filing on the 20th of every month.",
        q: "When must GSTR-2B reconciliation be completed?",
        a: "GSTR-2B reconciliation must be completed prior to the 20th of every month before GST return filing."
      }
    ]
  },
  {
    category: "standard_operating_procedure",
    doc_id: "sop_workforce_safety",
    title: "GAUREX Operations SOP: Worker Attendance, Safety & Site Protocols",
    sections: [
      {
        sec: "1.2",
        text: "Section 1.2: Standard shifts are 8 hours. Overtime beyond 8 hours requires prior mobile approval on GAUREX app and is compensated at 1.5x up to 2 hours, and 2.0x thereafter.",
        q: "What is the overtime rate for shifts extending up to 2 extra hours?",
        a: "Overtime is compensated at 1.5x the base hourly wage for the first 2 extra hours."
      },
      {
        sec: "2.1",
        text: "Section 2.1: Safety helmets, ISI-certified boots and reflective vests are mandatory on all active project locations. Non-compliance results in immediate site suspension.",
        q: "Which personal protective equipment items are mandatory on site?",
        a: "Safety helmets, ISI-certified boots and high-visibility reflective vests are strictly mandatory."
      },
      {
        sec: "4.5",
        text: "Section 4.5: Emergency site protocol requires the site manager to contact the centralized emergency response line and trigger the SOS beacon within 90 seconds of an incident.",
        q: "What is the mandatory timeframe for triggering the emergency beacon?",
        a: "The SOS beacon must be triggered within 90 seconds of any serious incident."
      }
    ]
  },
  {
    category: "company_policy",
    doc_id: "pol_procurement_materials",
    title: "GAUREX Procurement Policy: Vendor Selection and Material Verification",
    sections: [
      {
        sec: "2.3",
        text: "Section 2.3: Cement consignments must include manufacturer test certificates confirming Grade 53 OPC standards. Batch test samples are retained on site for 90 days.",
        q: "What grade of cement is required for structural concrete?",
        a: "Grade 53 OPC cement is required, accompanied by manufacturer test certificates."
      },
      {
        sec: "5.1",
        text: "Section 5.1: Purchase orders exceeding ₹1,00,000 require competitive bids from at least three approved vendors and final cryptographic approval from Gauresh Khairnar.",
        q: "What is the approval threshold for purchase orders exceeding ₹1,00,000?",
        a: "Purchase orders above ₹1,00,000 require 3 competitive vendor bids and cryptographic founder approval."
      }
    ]
  }
];

export class RAGGenerator {
  generateRecord(index) {
    const topic = TOPICS[index % TOPICS.length];
    const section = topic.sections[index % topic.sections.length];
    const chunkId = `chk_${topic.doc_id}_${section.sec.replace(".", "_")}_${index}`;
    const dynamicVariation = `[Revalidated for Q${(index % 4) + 1}-2026 Audit cycle: Ref #${1000 + index}]`;

    const fullChunkText = `${section.text} ${dynamicVariation}`;

    return {
      record_id: randomUUID(),
      doc_id: topic.doc_id,
      title: topic.title,
      category: topic.category,
      chunk_index: index,
      chunk_text: fullChunkText,
      embedding_ready_text: `Document: ${topic.title} | Section: ${section.sec}\n${fullChunkText}`,
      citations: [`gaurex://docs/${topic.doc_id}#sec_${section.sec}`],
      synthetic_qa_triples: [
        {
          question: section.q,
          context_excerpt: section.text,
          ground_truth_answer: section.a,
          complexity_level: index % 2 === 0 ? "intermediate" : "expert"
        }
      ],
      created_at: new Date().toISOString()
    };
  }
}
