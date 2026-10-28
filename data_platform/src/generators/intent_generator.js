/**
 * GAUREX AI Co-Founder - Voice Commands & Intent Recognition Generator
 */

import { randomUUID } from "node:crypto";

const CLIENT_NAMES = [
  "Sharma Logistics", "Apex Infrastructure", "Zenith Tech Systems", "Maharashtra Agro",
  "Royal Heights", "Kalyani Steelworks", "Tata BlueScope", "Piramal Realty", "Godrej Pune"
];

const INTENT_TYPES = [
  "finance.create_invoice",
  "finance.get_outstanding",
  "crm.lookup_client",
  "workforce.run_payroll",
  "analytics.revenue_forecast",
  "inventory.check_stock"
];

export class IntentGenerator {
  generateRecord(index) {
    const client = CLIENT_NAMES[index % CLIENT_NAMES.length];
    const intentType = INTENT_TYPES[index % INTENT_TYPES.length];
    const amount = ((index * 3210) % 900000) + 15000;
    const invNum = 1000 + (index % 4000);
    const days = (index % 60) + 1;
    const lang = ["en", "hi", "mr", "hi-en"][index % 4];

    let utterance = "";
    let domain = "finance";
    let requiredTool = "generate_tax_invoice";
    let riskLevel = "low_risk_write";
    let slots = {};

    switch (intentType) {
      case "finance.create_invoice":
        domain = "finance";
        requiredTool = "generate_tax_invoice";
        riskLevel = "low_risk_write";
        slots = { client_name: client, amount, gst_rate: 0.18, currency: "INR" };
        if (lang === "en") utterance = `Generate a tax invoice for ${client} amounting to ₹${amount.toLocaleString("en-IN")} with 18% GST.`;
        else if (lang === "hi") utterance = `${client} के लिए ₹${amount.toLocaleString("en-IN")} का 18% जीएसटी इनवॉइस बनाओ।`;
        else if (lang === "mr") utterance = `${client} साठी ₹${amount.toLocaleString("en-IN")} चे 18% जीएसटी बिल तयार करा.`;
        else utterance = `${client} ke liye ₹${amount.toLocaleString("en-IN")} ka invoice 18% GST ke sath bana do.`;
        break;

      case "finance.get_outstanding":
        domain = "finance";
        requiredTool = "query_unpaid_invoices";
        riskLevel = "read_only";
        slots = { client_name: client, days_older_than: days };
        if (lang === "en") utterance = `Show outstanding balance for ${client} pending for more than ${days} days.`;
        else if (lang === "hi") utterance = `${client} का पिछले ${days} दिनों का बाकी पेमेंट दिखाओ।`;
        else if (lang === "mr") utterance = `${client} कडून गेल्या ${days} दिवसांपासून येणे बाकी रक्कम दाखवा.`;
        else utterance = `${client} ka ${days} din se bacha hua balance check karo.`;
        break;

      case "crm.lookup_client":
        domain = "crm";
        requiredTool = "search_client_directory";
        riskLevel = "read_only";
        slots = { client_query: client };
        if (lang === "en") utterance = `Open client profile, recent invoices and contract status for ${client}.`;
        else if (lang === "hi") utterance = `${client} का प्रोफाइल और लेटेस्ट आर्डर्स की डिटेल्स खोलो।`;
        else if (lang === "mr") utterance = `${client} ची सर्व माहिती आणि नवीन करारांची यादी दाखवा.`;
        else utterance = `${client} ka company profile aur contract history screen pe open karo.`;
        break;

      case "workforce.run_payroll":
        domain = "workforce";
        requiredTool = "execute_direct_bank_transfer";
        riskLevel = "high_risk_financial";
        slots = { total_payout: amount, group: "site_workers" };
        if (lang === "en") utterance = `Authorize worker salary transfer of ₹${amount.toLocaleString("en-IN")} for this pay period.`;
        else if (lang === "hi") utterance = `सभी वर्कर्स के बैंक खातों में ₹${amount.toLocaleString("en-IN")} का सैलरी ट्रांसफर अप्रूव करो।`;
        else if (lang === "mr") utterance = `कामगारांच्या खात्यात ₹${amount.toLocaleString("en-IN")} वेतनाचा थेट भरणा मंजूर करा.`;
        else utterance = `Workers ke bank account me ₹${amount.toLocaleString("en-IN")} payroll disbursement process karo.`;
        break;

      case "analytics.revenue_forecast":
        domain = "analytics";
        requiredTool = "compute_predictive_cashflow";
        riskLevel = "read_only";
        slots = { horizon: "next_quarter", metric: "net_cashflow" };
        if (lang === "en") utterance = `Compute projected cash surplus and tax liabilities for the upcoming quarter.`;
        else if (lang === "hi") utterance = `अगले तीन महीनों का कैश फ्लो और नेट प्रॉफिट मार्जिन का अनुमान लगाओ।`;
        else if (lang === "mr") utterance = `पुढील तिमाहीतील अंदाजे शिल्लक रोकड आणि करदायित्वाचा अंदाज दाखवा.`;
        else utterance = `Next quarter ka financial projection aur cash surplus forecast dikhao.`;
        break;

      case "inventory.check_stock":
      default:
        domain = "operations";
        requiredTool = "query_site_materials";
        riskLevel = "read_only";
        slots = { material: "cement_bags", site: "Pune Project Alpha" };
        if (lang === "en") utterance = `Check current cement and steel stock levels for Pune Project Alpha.`;
        else if (lang === "hi") utterance = `पुणे प्रोजेक्ट अल्फा के लिए सीमेंट और स्टील का स्टॉक चेक करो।`;
        else if (lang === "mr") utterance = `पुणे प्रोजेक्ट अल्फा वरील सिमेंट व स्टीलचा सध्याचा साठा तपासा.`;
        else utterance = `Pune Project Alpha pe material stock kitna bacha hai report karo.`;
        break;
    }

    const entities = [
      { entity: "client_name", value: client, start_char: utterance.indexOf(client), end_char: utterance.indexOf(client) + client.length }
    ];

    return {
      record_id: randomUUID(),
      utterance,
      language: lang,
      intent: intentType,
      domain,
      slots,
      entities,
      required_tool: requiredTool,
      risk_level: riskLevel,
      requires_confirmation: riskLevel === "high_risk_financial",
      expected_response_template: `Executed ${intentType} successfully for Gauresh Khairnar (OWNER).`,
      created_at: new Date().toISOString()
    };
  }
}
