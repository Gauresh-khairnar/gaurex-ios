/**
 * GAUREX AI Co-Founder - Mathematically Consistent Business Intelligence Generator
 * Models transactions, GST slabs, cash flow, receivables and predictive anomaly flags.
 */

import { randomUUID } from "node:crypto";

const CLIENTS = [
  { id: "cli_sharma_01", name: "Sharma Logistics Ltd", city: "Mumbai", avg_ticket: 85000 },
  { id: "cli_apex_02", name: "Apex Infrastructure Group", city: "Pune", avg_ticket: 240000 },
  { id: "cli_zenith_03", name: "Zenith Tech Systems", city: "Bengaluru", avg_ticket: 150000 },
  { id: "cli_maharashtra_04", name: "Maharashtra Agro Warehousing", city: "Nashik", avg_ticket: 95000 },
  { id: "cli_royal_05", name: "Royal Heights Construction", city: "Thane", avg_ticket: 320000 }
];

const GST_SLABS = [0.05, 0.12, 0.18, 0.28];
const STATUS_OPTIONS = ["paid", "pending", "overdue", "disputed"];

export class BIGenerator {
  generateRecord(index) {
    const client = CLIENTS[index % CLIENTS.length];
    const gstRate = GST_SLABS[index % GST_SLABS.length];

    // Calculate baseline subtotal with reproducible variance
    const multiplier = 0.5 + ((index * 37) % 150) / 100.0; // 0.5x to 2.0x
    const amountSubtotal = Math.round(client.avg_ticket * multiplier * 100) / 100;
    const gstAmount = Math.round(amountSubtotal * gstRate * 100) / 100;
    const amountTotal = Math.round((amountSubtotal + gstAmount) * 100) / 100;

    const status = STATUS_OPTIONS[index % STATUS_OPTIONS.length];
    let daysOutstanding = 0;
    if (status === "pending") daysOutstanding = (index % 30) + 1;
    if (status === "overdue") daysOutstanding = 31 + (index % 70);
    if (status === "disputed") daysOutstanding = 45 + (index % 60);

    // Anomaly detection rules
    const anomalyFlags = [];
    let anomalyScore = 0.05;

    if (daysOutstanding > 60) {
      anomalyFlags.push("late_payment_pattern");
      anomalyScore += 0.45;
    }
    if (multiplier > 1.85) {
      anomalyFlags.push("unusual_amount_spike");
      anomalyScore += 0.35;
    }
    if (index % 47 === 0) {
      anomalyFlags.push("duplicate_invoice_candidate");
      anomalyScore += 0.40;
    }
    if (anomalyFlags.length === 0) {
      anomalyFlags.push("none");
    }

    anomalyScore = Math.min(1.0, Math.round(anomalyScore * 100) / 100);

    return {
      record_id: randomUUID(),
      entity_type: "tax_invoice",
      invoice_number: `INV-2026-${String(1000 + index).padStart(6, "0")}`,
      client_id: client.id,
      client_name: client.name,
      client_city: client.city,
      amount_subtotal: amountSubtotal,
      gst_rate: gstRate,
      gst_amount: gstAmount,
      amount_total: amountTotal,
      currency: "INR",
      payment_status: status,
      days_outstanding: daysOutstanding,
      due_date: new Date(Date.now() + (30 - daysOutstanding) * 86400000).toISOString().split("T")[0],
      anomaly_flags: anomalyFlags,
      anomaly_score: anomalyScore,
      math_verified: true,
      created_at: new Date().toISOString()
    };
  }
}
