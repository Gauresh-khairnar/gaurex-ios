/**
 * GAUREX AI Co-Founder - Agentic AI & Tool Trajectory Dataset Generator
 */

import { randomUUID } from "node:crypto";

const CLIENTS = [
  "Sharma Logistics", "Apex Infrastructure", "Zenith Tech Systems", "Maharashtra Agro",
  "Royal Heights Developers", "Kalyani Steelworks", "Tata BlueScope", "Piramal Realty"
];

const CITIES = ["Mumbai", "Pune", "Nashik", "Nagpur", "Thane"];

export class AgenticGenerator {
  generateRecord(index) {
    const client = CLIENTS[index % CLIENTS.length];
    const city = CITIES[index % CITIES.length];
    const amount = ((index * 4150) % 750000) + 25000;
    const daysLate = 30 + (index % 45);
    const workerCount = 15 + (index % 35);
    const payrollAmount = workerCount * 12500;

    const scenarios = [
      {
        goal: `Audit overdue invoices for ${client} in ${city}, compute penalty interest, and send payment reminder with founder authorization.`,
        tools: ["get_client_invoices", "calculate_penalty_interest", "draft_payment_reminder", "request_founder_approval", "dispatch_whatsapp_message"],
        trajectory: [
          {
            step: 1,
            thought: `Fetching unpaid records for ${client} to determine outstanding days and principal balance.`,
            action: "get_client_invoices",
            action_input: { client_name: client, status: "unpaid" },
            observation: { unpaid_count: 1, principal: amount, days_overdue: daysLate },
            requires_human_approval: false
          },
          {
            step: 2,
            thought: `Invoice is ${daysLate} days overdue. Applying monthly late penalty rate of 1.5%.`,
            action: "calculate_penalty_interest",
            action_input: { principal: amount, days_late: daysLate, annual_rate: 0.18 },
            observation: { interest: Math.round(amount * 0.015 * (daysLate / 30)), total: amount + Math.round(amount * 0.015 * (daysLate / 30)) },
            requires_human_approval: false
          },
          {
            step: 3,
            thought: `Drafting formal notice to ${client} finance department.`,
            action: "draft_payment_reminder",
            action_input: { client_name: client, total_due: amount, location: city },
            observation: { draft_id: `draft_${index}_${client.substring(0, 3)}` },
            requires_human_approval: false
          },
          {
            step: 4,
            thought: `External financial notices require explicit founder signoff from Gauresh Khairnar (OWNER).`,
            action: "request_founder_approval",
            action_input: { target_client: client, amount: amount, action: "send_overdue_notice" },
            observation: { status: "APPROVED", authorized_by: "Gauresh Khairnar" },
            requires_human_approval: true
          },
          {
            step: 5,
            thought: `Founder authorized. Dispatching official notification via WhatsApp API.`,
            action: "dispatch_whatsapp_message",
            action_input: { client: client, dispatch_verified: true },
            observation: { delivery_status: "SUCCESS" },
            requires_human_approval: false
          }
        ],
        final_response: `Overdue audit for ${client} completed. Reminder for ₹${amount.toLocaleString("en-IN")} dispatched following founder approval.`
      },
      {
        goal: `Reconcile shift biometric attendance for ${workerCount} workers at ${city} site and process payroll.`,
        tools: ["get_site_attendance", "compute_payroll_taxes", "request_founder_approval", "execute_bank_transfer"],
        trajectory: [
          {
            step: 1,
            thought: `Aggregating biometric logs for ${workerCount} workers at ${city} project site.`,
            action: "get_site_attendance",
            action_input: { site: `${city} Site`, active_workers: workerCount },
            observation: { total_shifts: workerCount * 25, overtime_hours: workerCount * 4 },
            requires_human_approval: false
          },
          {
            step: 2,
            thought: `Calculating statutory deductions and net disbursements.`,
            action: "compute_payroll_taxes",
            action_input: { worker_count: workerCount, base_payout: payrollAmount },
            observation: { gross: payrollAmount, net: Math.round(payrollAmount * 0.95) },
            requires_human_approval: false
          },
          {
            step: 3,
            thought: `Bank disbursement of ₹${payrollAmount.toLocaleString("en-IN")} requires biometric/PIN signoff by Gauresh Khairnar.`,
            action: "request_founder_approval",
            action_input: { payout_amount: payrollAmount, workers: workerCount },
            observation: { status: "APPROVED", authorized_by: "Gauresh Khairnar" },
            requires_human_approval: true
          },
          {
            step: 4,
            thought: `Signoff confirmed. Initiating direct NEFT/IMPS payroll batch.`,
            action: "execute_bank_transfer",
            action_input: { batch_amount: payrollAmount, batch_count: workerCount },
            observation: { status: "PROCESSED", transaction_batch_id: `tx_${index}` },
            requires_human_approval: false
          }
        ],
        final_response: `Biometric attendance verified and ₹${payrollAmount.toLocaleString("en-IN")} payroll disbursed to ${workerCount} workers at ${city}.`
      }
    ];

    const scenario = scenarios[index % scenarios.length];

    return {
      record_id: randomUUID(),
      user_goal: scenario.goal,
      domain: "business_orchestration",
      initial_state: { founder_context: "Gauresh Khairnar (OWNER)", app_version: "2.0.0", index },
      trajectory: scenario.trajectory,
      final_response: scenario.final_response,
      tools_invoked: scenario.tools,
      success: true,
      requires_founder_approval: scenario.trajectory.some(t => t.requires_human_approval),
      created_at: new Date().toISOString()
    };
  }
}
