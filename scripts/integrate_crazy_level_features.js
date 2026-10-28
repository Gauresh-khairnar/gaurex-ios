const fs = require('fs');
const path = require('path');

// 1. Update DashboardView.swift
const dashboardPath = path.join(__dirname, '..', 'Gaurex', 'Views', 'Dashboard', 'DashboardView.swift');
let dashboardContent = fs.readFileSync(dashboardPath, 'utf8');

// Normalize CRLF to LF
let content = dashboardContent.replace(/\r\n/g, '\n');

// Add showingGhostSimulatorSheet state
const stateTarget = `@State private var showingAddExpenseSheet = false`;
const stateReplacement = `@State private var showingAddExpenseSheet = false
    @State private var showingGhostSimulatorSheet = false`;

if (!content.includes('showingGhostSimulatorSheet')) {
    content = content.replace(stateTarget, stateReplacement);
}

// In Top Header: Add Stealth Shield Eye Button
const bellButtonOld = `                            // Bell Notifications Button with Live Yellow Indicator Dot`;
const stealthButtonAndBell = `                            // Stealth Privacy Shield Button
                            Button {
                                store.toggleStealthPrivacy()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.22) : Color.white)
                                        .frame(width: 42, height: 42)
                                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                                    
                                    Image(systemName: store.isStealthPrivacyActive ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(store.isStealthPrivacyActive ? Color.red : goldAccent)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            // Bell Notifications Button with Live Yellow Indicator Dot`;

if (!content.includes('store.toggleStealthPrivacy()')) {
    content = content.replace(bellButtonOld, stealthButtonAndBell);
}

// Replace the Total Revenue Card with 3D Holographic Hero Card + Founder Velocity Rings
const oldRevenueCardBlock = `                        // MARK: - Total Revenue Card with Flowing Sparkline Wave
                        Button {
                            showingProfitCenter = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.05), radius: 14, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                                    )
                                
                                // Content
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 8) {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(Color(red: 0.24, green: 0.12, blue: 0.36).opacity(0.08))
                                                .frame(width: 36, height: 36)
                                                .overlay(
                                                    Image(systemName: "chart.bar.xaxis")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(deepPurple)
                                                )
                                            
                                            Text("Net Operating Cashflow")
                                                .font(.pjs(13, weight: .medium))
                                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                        }
                                        
                                        // Real live verified store data
                                        Text(FinancialCalculator.shared.formatCurrency(store.netOperatingRevenue, symbol: store.settings.currencySymbol))
                                            .font(.pjs(26, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                        
                                        HStack(spacing: 8) {
                                            HStack(spacing: 3) {
                                                Image(systemName: "arrow.down.left")
                                                    .font(.system(size: 10, weight: .bold))
                                                Text("In: \\(FinancialCalculator.shared.formatCurrency(store.revenueCollected, symbol: store.settings.currencySymbol))")
                                                    .font(.pjs(11, weight: .semibold))
                                            }
                                            .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                                            
                                            Text("•")
                                                .foregroundColor(Color(uiColor: .tertiaryLabel))
                                            
                                            HStack(spacing: 3) {
                                                Image(systemName: "arrow.up.right")
                                                    .font(.system(size: 10, weight: .bold))
                                                Text("Exp: -\\(FinancialCalculator.shared.formatCurrency(store.allOperationalExpenses, symbol: store.settings.currencySymbol))")
                                                    .font(.pjs(11, weight: .semibold))
                                            }
                                            .foregroundColor(Color(red: 0.92, green: 0.28, blue: 0.28))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Flowing Bezier Sparkline Chart
                                    ZStack {
                                        SparklineWaveShape()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        deepPurple,
                                                        goldAccent
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 2.2
                                            )
                                            .frame(width: 130, height: 56)
                                        
                                        // Golden inflection node on peak
                                        Circle()
                                            .fill(goldAccent)
                                            .frame(width: 8, height: 8)
                                            .shadow(color: goldAccent.opacity(0.8), radius: sparklinePulse ? 6 : 2)
                                            .offset(x: 15, y: -16)
                                    }
                                }
                                .padding(20)
                                
                                // Live Pill Badge
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(Color(red: 0.06, green: 0.72, blue: 0.44))
                                        .frame(width: 6, height: 6)
                                    Text("Live Sync")
                                        .font(.pjs(11, weight: .bold))
                                        .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.06, green: 0.72, blue: 0.44).opacity(0.10))
                                .clipShape(Capsule())
                                .padding(14)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        .offset(y: animateRevenueCard ? 0 : 25)
                        .opacity(animateRevenueCard ? 1 : 0)`;

const newHeroCardBlock = `                        // MARK: - 3D Holographic Gyroscope Hero Card
                        HolographicFounderHeroCard {
                            showingProfitCenter = true
                        }
                        .padding(.horizontal, 24)
                        .offset(y: animateRevenueCard ? 0 : 25)
                        .opacity(animateRevenueCard ? 1 : 0)
                        
                        // MARK: - Founder Velocity 3-Ring Activity Center
                        FounderVelocityRingsView()
                            .padding(.horizontal, 24)`;

content = content.replace(oldRevenueCardBlock, newHeroCardBlock);

// In Quick Actions: Update Tile 6 to Ghost Simulator
const profitCenterTile = `                                // 6. Profit Center
                                QuickActionCardTile(
                                    icon: "chart.line.uptrend.xyaxis",
                                    iconColor: goldAccent,
                                    title: "Profit Center",
                                    subtitle: "P&L and margins"
                                ) {
                                    showingProfitCenter = true
                                }`;

const ghostSimulatorTile = `                                // 6. Ghost Simulator
                                QuickActionCardTile(
                                    icon: "wand.and.stars",
                                    iconColor: goldAccent,
                                    title: "Ghost Simulator",
                                    subtitle: "What-If war games"
                                ) {
                                    showingGhostSimulatorSheet = true
                                }`;

content = content.replace(profitCenterTile, ghostSimulatorTile);

// Add sheet for GhostRunwaySimulatorSheet
const oldSheetEnd = `.sheet(isPresented: $showingAddExpenseSheet) {
                AddExpenseSheet()
            }`;

const newSheetEnd = `.sheet(isPresented: $showingAddExpenseSheet) {
                AddExpenseSheet()
            }
            .sheet(isPresented: $showingGhostSimulatorSheet) {
                GhostRunwaySimulatorSheet()
            }`;

if (!content.includes('GhostRunwaySimulatorSheet()')) {
    content = content.replace(oldSheetEnd, newSheetEnd);
}

fs.writeFileSync(dashboardPath, content, 'utf8');
console.log('DashboardView.swift successfully upgraded with 3D Card, Stealth Shield, Velocity Rings, and Simulator!');

// 2. Update FinanceProfitCenterView.swift to embed ExecutiveGoldVaultSlider into AddExpenseSheet
const financePath = path.join(__dirname, '..', 'Gaurex', 'Views', 'Dashboard', 'FinanceProfitCenterView.swift');
let financeContent = fs.readFileSync(financePath, 'utf8').replace(/\r\n/g, '\n');

const oldExpenseForm = `                Section(header: Text("Notes")) {
                    TextField("Memo / Notes", text: $notes)
                }
            }
            .navigationTitle("Log Expense")`;

const newExpenseForm = `                Section(header: Text("Notes")) {
                    TextField("Memo / Notes", text: $notes)
                }
                
                Section {
                    ExecutiveGoldVaultSlider(
                        title: "Slide to Authorize Expense",
                        subtitle: "Deducts live cashflow immediately",
                        icon: "creditcard.fill"
                    ) {
                        guard !title.isEmpty, amount > 0 else { return }
                        let exp = Expense(
                            title: title,
                            category: category,
                            amount: amount,
                            date: date,
                            paymentMethod: paymentMethod,
                            vendorName: vendor,
                            notes: notes
                        )
                        store.addExpense(exp)
                        dismiss()
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Log Expense")`;

if (!financeContent.includes('ExecutiveGoldVaultSlider')) {
    financeContent = financeContent.replace(oldExpenseForm, newExpenseForm);
    fs.writeFileSync(financePath, financeContent, 'utf8');
    console.log('FinanceProfitCenterView.swift successfully upgraded with ExecutiveGoldVaultSlider!');
}
