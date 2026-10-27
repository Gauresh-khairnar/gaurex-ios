//
//  AIService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive Chief of Staff & High-Leverage Strategic AI Engine
//

import Foundation

public struct AIAnalysisContext {
    public let totalClients: Int
    public let activeClients: Int
    public let totalWorkers: Int
    public let totalInvoiced: Double
    public let revenueCollected: Double
    public let outstandingPayments: Double
    public let overdueInvoicesCount: Int
    public let monthlyOperatingExpenses: Double
    public let monthlyPayrollExpenses: Double
    public let netOperatingIncome: Double
    public let activeProjectsCount: Int
    public let currencySymbol: String
    public let topOverdueClients: [(name: String, balance: Double)]
    public let packageRevenueBreakdown: [(packageName: String, revenue: Double)]
    
    public let founderName: String = "Gauresh Khairnar (OWNER)"
    
    public init(
        totalClients: Int,
        activeClients: Int,
        totalInvoiced: Double,
        revenueCollected: Double,
        outstandingPayments: Double,
        overdueInvoicesCount: Int,
        totalWorkers: Int,
        monthlyPayrollExpenses: Double,
        monthlyOperatingExpenses: Double,
        netOperatingIncome: Double,
        activeProjectsCount: Int,
        currencySymbol: String,
        topOverdueClients: [(name: String, balance: Double)] = [],
        packageRevenueBreakdown: [(packageName: String, revenue: Double)] = []
    ) {
        self.totalClients = totalClients
        self.activeClients = activeClients
        self.totalInvoiced = totalInvoiced
        self.revenueCollected = revenueCollected
        self.outstandingPayments = outstandingPayments
        self.overdueInvoicesCount = overdueInvoicesCount
        self.totalWorkers = totalWorkers
        self.monthlyOperatingExpenses = monthlyOperatingExpenses
        self.monthlyPayrollExpenses = monthlyPayrollExpenses
        self.netOperatingIncome = netOperatingIncome
        self.activeProjectsCount = activeProjectsCount
        self.currencySymbol = currencySymbol
        self.topOverdueClients = topOverdueClients
        self.packageRevenueBreakdown = packageRevenueBreakdown
    }
}

public final class AIService: ObservableObject {
    public static let shared = AIService()
    
    @Published public var isAnalyzing: Bool = false
    @Published public var lastAnalysisError: String? = nil
    
    private static var defaultRuntimeGroqKey: String {
        // Obfuscated credential payload decoded at runtime into iOS Keychain
        let payload = "Z3NrX3F6cnJaYnZaTU9adjJFNW14bGxlWVdHZHlyYUZYeEhpbHV5cEVPSnBuQkxoRmU4U0hnVXhN"
        if let data = Data(base64Encoded: payload), let decoded = String(data: data, encoding: .utf8) {
            return decoded
        }
        return ""
    }
    
    public var defaultGroqApiKey: String {
        Self.defaultRuntimeGroqKey
    }
    public let defaultGroqModel = "llama-3.3-70b-versatile"
    public let fallbackGroqModel = "llama-3.1-8b-instant"
    
    private init() {
        // Ensure default Groq key is initialized in Keychain if empty
        if KeychainService.shared.readSecret(key: "gaurex_ai_api_key") == nil {
            _ = KeychainService.shared.saveSecret(key: "gaurex_ai_api_key", value: defaultGroqApiKey)
        }
    }
    
    /// Returns the active API key (from Keychain or default Groq key)
    public var activeApiKey: String {
        KeychainService.shared.readSecret(key: "gaurex_ai_api_key") ?? defaultGroqApiKey
    }
    
    /// Tests connectivity to Groq API
    public func testConnection(provider: String, model: String, completion: @escaping (Bool, String) -> Void) {
        let key = activeApiKey
        guard let url = URL(string: "https://api.groq.com/openai/v1/models") else {
            completion(false, "Invalid Groq endpoint URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 8.0
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "Connection error: \(error.localizedDescription)")
                    return
                }
                if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                    completion(true, "Successfully connected to Groq ultra-fast LPU inference engine.")
                } else {
                    completion(false, "Groq authentication failed. Please check credentials.")
                }
            }
        }.resume()
    }
    
    /// Queries Groq AI with live business context as Gauresh's Chief of Staff
    public func askBusinessAssistant(
        question: String,
        context: AIAnalysisContext,
        completion: @escaping (AIMessage) -> Void
    ) {
        isAnalyzing = true
        lastAnalysisError = nil
        
        let overdueClientSummary = context.topOverdueClients.isEmpty
            ? "None"
            : context.topOverdueClients.map { "\($0.name): \(context.currencySymbol)\(String(format: "%.2f", $0.balance))" }.joined(separator: ", ")
        
        let systemPrompt = """
        You are the personal GAUREX Chief of Staff & Strategic Executive Advisor built exclusively for Founder & Owner Gauresh Khairnar (OWNER).
        GAUREX is an elite enterprise technology, digital architecture, and bespoke software solutions company.
        
        CURRENT VERIFIED BUSINESS METRICS:
        - Founder / Owner: Gauresh Khairnar
        - Total Invoiced Revenue: \(context.currencySymbol)\(String(format: "%.2f", context.totalInvoiced))
        - Actual Collected Liquid Revenue: \(context.currencySymbol)\(String(format: "%.2f", context.revenueCollected))
        - Outstanding Client Receivables: \(context.currencySymbol)\(String(format: "%.2f", context.outstandingPayments))
        - Overdue Invoices Count: \(context.overdueInvoicesCount)
        - Overdue Accounts: \(overdueClientSummary)
        - Monthly Operating Expenses: \(context.currencySymbol)\(String(format: "%.2f", context.monthlyOperatingExpenses))
        - Worker Payroll Commitments: \(context.currencySymbol)\(String(format: "%.2f", context.monthlyPayrollExpenses))
        - Net Operating Income / Profit: \(context.currencySymbol)\(String(format: "%.2f", context.netOperatingIncome))
        - Client Base: \(context.totalClients) total (\(context.activeClients) active contracts)
        - Team Capacity: \(context.totalWorkers) core members across \(context.activeProjectsCount) active projects
        
        EXECUTIVE ADVISORY PROTOCOL:
        1. Always address Gauresh Khairnar directly with executive sharpness, brevity, and data-driven tactical clarity.
        2. Never give generic boilerplate. Ground your answers directly in the numbers above.
        3. Structure responses with clean Markdown: bold headers, crisp bullet points, and actionable next steps.
        4. Focus on cashflow acceleration, closing high-ticket deals, protecting profit margins, and team velocity.
        """
        
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            fallbackLocalAssistant(question: question, context: context, completion: completion)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(activeApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 12.0
        
        let payload: [String: Any] = [
            "model": defaultGroqModel,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": question]
            ],
            "temperature": 0.4,
            "max_tokens": 750
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.lastAnalysisError = error.localizedDescription
                    self.fallbackLocalAssistant(question: question, context: context, completion: completion)
                }
                return
            }
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                let isForecast = content.contains("forecast") || content.contains("projection") || content.contains("run-rate")
                
                // Extract an actionable recommendation if available
                var recommendation: String? = nil
                if let line = content.components(separatedBy: "\n").first(where: {
                    $0.lowercased().contains("recommend") || $0.lowercased().contains("action:") || $0.lowercased().contains("next step")
                }) {
                    recommendation = line.replacingOccurrences(of: "**", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                let aiResponse = AIMessage(
                    sender: "assistant",
                    content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                    actionRecommendation: recommendation,
                    isForecastEstimate: isForecast
                )
                
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    completion(aiResponse)
                }
            } else {
                DispatchQueue.main.async {
                    self.fallbackLocalAssistant(question: question, context: context, completion: completion)
                }
            }
        }.resume()
    }
    
    /// Generates structured daily execution tasks tailored to current business pulse
    public func generateSmartDayPlan(
        context: AIAnalysisContext,
        completion: @escaping ([BusinessTask]) -> Void
    ) {
        isAnalyzing = true
        
        let prompt = """
        Analyze GAUREX business state for Founder Gauresh Khairnar:
        - Collected Revenue: \(context.currencySymbol)\(context.revenueCollected)
        - Invoiced: \(context.currencySymbol)\(context.totalInvoiced)
        - Pending Receivables: \(context.currencySymbol)\(context.outstandingPayments)
        - Overdue Invoices: \(context.overdueInvoicesCount)
        - Active Clients: \(context.activeClients)
        - Operating Expenses: \(context.currencySymbol)\(context.monthlyOperatingExpenses)
        
        Generate the 3 highest-leverage, non-negotiable executive priorities for Gauresh today to maximize revenue and cash collections.
        Return ONLY a JSON array of tasks with this exact structure:
        [
          {
            "title": "Task title",
            "description": "Detailed execution steps",
            "category": "Sales CRM" or "Financial" or "Engineering" or "Executive",
            "priority": "Urgent" or "High" or "Medium",
            "durationMinutes": 30,
            "aiReasoning": "Why this directly drives revenue or operating efficiency"
          }
        ]
        """
        
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            self.isAnalyzing = false
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(activeApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 12.0
        
        let payload: [String: Any] = [
            "model": defaultGroqModel,
            "messages": [
                ["role": "system", "content": "You are a master business operating strategist. Return valid JSON array only."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 800
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self = self else { return }
            
            var generatedTasks: [BusinessTask] = []
            let calendar = Calendar.current
            var slot = calendar.date(bySettingHour: 9, minute: 30, second: 0, of: Date()) ?? Date()
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let content = choices.first?["message"] as? [String: Any],
               let text = content["content"] as? String {
                
                if let startIdx = text.range(of: "["),
                   let endIdx = text.range(of: "]", options: .backwards) {
                    let jsonSub = String(text[startIdx.lowerBound...endIdx.upperBound])
                    if let subData = jsonSub.data(using: .utf8),
                       let taskItems = try? JSONSerialization.jsonObject(with: subData) as? [[String: Any]] {
                        for item in taskItems {
                            let title = item["title"] as? String ?? "Executive Milestone"
                            let desc = item["description"] as? String ?? ""
                            let cat = item["category"] as? String ?? "Executive"
                            let pRaw = item["priority"] as? String ?? "High"
                            let dur = item["durationMinutes"] as? Int ?? 30
                            let reason = item["aiReasoning"] as? String ?? "Drives core business growth"
                            
                            let priority: TaskPriority = (pRaw == "Urgent") ? .urgent : ((pRaw == "High") ? .high : .medium)
                            
                            let task = BusinessTask(
                                title: title,
                                taskDescription: desc,
                                category: cat,
                                priority: priority,
                                dueDate: Date(),
                                scheduledStartTime: slot,
                                estimatedDurationMinutes: dur,
                                isAiGenerated: true,
                                aiReasoning: reason
                            )
                            generatedTasks.append(task)
                            slot = calendar.date(byAdding: .minute, value: dur + 15, to: slot) ?? slot
                        }
                    }
                }
            }
            
            // Fallback generated tasks if offline or parse error
            if generatedTasks.isEmpty {
                generatedTasks = [
                    BusinessTask(
                        title: "Enterprise Client Outreach & Retainer Pitching",
                        taskDescription: "Follow up with high-priority enterprise prospects to close upcoming development retainers.",
                        category: "Sales CRM",
                        priority: .urgent,
                        dueDate: Date(),
                        scheduledStartTime: slot,
                        estimatedDurationMinutes: 45,
                        isAiGenerated: true,
                        aiReasoning: "Converts active sales pipeline directly into collected cash."
                    ),
                    BusinessTask(
                        title: "Outstanding Receivables Collection",
                        taskDescription: "Review overdue client accounts and issue instant payment settlement reminders.",
                        category: "Financial",
                        priority: .high,
                        dueDate: Date(),
                        scheduledStartTime: calendar.date(byAdding: .minute, value: 60, to: slot),
                        estimatedDurationMinutes: 30,
                        isAiGenerated: true,
                        aiReasoning: "Recovers \(context.currencySymbol)\(String(format: "%.0f", context.outstandingPayments)) in pending client receivables."
                    ),
                    BusinessTask(
                        title: "Operations & Delivery Velocity Review",
                        taskDescription: "Review project milestones across active development streams to ensure on-time delivery.",
                        category: "Engineering",
                        priority: .medium,
                        dueDate: Date(),
                        scheduledStartTime: calendar.date(byAdding: .minute, value: 120, to: slot),
                        estimatedDurationMinutes: 30,
                        isAiGenerated: true,
                        aiReasoning: "Ensures client satisfaction and unlocks milestone disbursements."
                    )
                ]
            }
            
            DispatchQueue.main.async {
                self.isAnalyzing = false
                completion(generatedTasks)
            }
        }.resume()
    }
    
    private func fallbackLocalAssistant(question: String, context: AIAnalysisContext, completion: @escaping (AIMessage) -> Void) {
        let sym = context.currencySymbol
        let lower = question.lowercased()
        var answer = ""
        var rec: String? = nil
        var isForecast = false
        
        if lower.contains("revenue") || lower.contains("money") || lower.contains("cash") {
            answer = """
            ### 💰 Financial Health Briefing for Gauresh Khairnar (OWNER):
            • **Collected Cash:** **\(sym)\(String(format: "%.2f", context.revenueCollected))** in verified liquid collections.
            • **Total Invoiced:** **\(sym)\(String(format: "%.2f", context.totalInvoiced))** across all enterprise contracts.
            • **Pending Receivables:** **\(sym)\(String(format: "%.2f", context.outstandingPayments))** awaiting collection.
            • **Net Operating Profit:** **\(sym)\(String(format: "%.2f", context.netOperatingIncome))** after monthly expenses.
            """
            rec = "Prioritize collecting the \(sym)\(String(format: "%.2f", context.outstandingPayments)) in pending receivables."
        } else if lower.contains("overdue") || lower.contains("invoice") {
            answer = """
            ### ⚠️ Outstanding Invoices Status:
            There are currently **\(context.overdueInvoicesCount) overdue invoices** totaling **\(sym)\(String(format: "%.2f", context.outstandingPayments))**.
            
            **Recommended Action:** Issue WhatsApp and official email payment reminders to unlock these funds immediately.
            """
            rec = "Dispatch invoice settlement reminders to overdue accounts today."
        } else if lower.contains("expense") || lower.contains("cost") || lower.contains("burn") {
            answer = """
            ### 📊 Operational Cost Breakdown:
            • **Monthly Operating Overhead:** **\(sym)\(String(format: "%.2f", context.monthlyOperatingExpenses))**
            • **Team Payroll Commitment:** **\(sym)\(String(format: "%.2f", context.monthlyPayrollExpenses))**
            • **Total Monthly Burn:** **\(sym)\(String(format: "%.2f", context.monthlyOperatingExpenses + context.monthlyPayrollExpenses))**
            • **Net Profit Margin:** **\(context.revenueCollected > 0 ? String(format: "%.1f", (context.netOperatingIncome / context.revenueCollected) * 100) : "0")%**
            """
            rec = "Maintain operating expenses below 20% of monthly collections to protect net margins."
        } else if lower.contains("plan") || lower.contains("today") || lower.contains("priority") {
            answer = """
            ### ⚡ Executive Day Plan for Gauresh Khairnar:
            1. **High-Ticket Sales Outreach:** Follow up with qualified enterprise pipeline prospects.
            2. **Receivable Recovery:** Collect on **\(sym)\(String(format: "%.2f", context.outstandingPayments))** in pending client balances.
            3. **Delivery Quality Assurance:** Check milestone progress with active team members.
            """
            rec = "Execute on sales follow-ups and receivable collections to maintain high cash velocity."
        } else {
            answer = """
            ### 👑 GAUREX Executive Chief of Staff Briefing:
            **Founder & Owner:** Gauresh Khairnar
            • **Active Clients:** \(context.activeClients) (\(context.totalClients) in CRM)
            • **Collected Cash:** \(sym)\(String(format: "%.2f", context.revenueCollected))
            • **Net Operating Income:** \(sym)\(String(format: "%.2f", context.netOperatingIncome))
            • **Pending Receivables:** \(sym)\(String(format: "%.2f", context.outstandingPayments))
            • **Core Team:** \(context.totalWorkers) members on \(context.activeProjectsCount) active projects
            
            How can I assist your strategic decision-making today, Gauresh?
            """
            rec = "Ask for revenue forecasts, cashflow breakdown, or tactical day plans."
        }
        
        let msg = AIMessage(
            sender: "assistant",
            content: answer,
            actionRecommendation: rec,
            isForecastEstimate: isForecast
        )
        self.isAnalyzing = false
        completion(msg)
    }
}
