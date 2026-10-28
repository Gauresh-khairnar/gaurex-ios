const fs = require('fs');
const path = require('path');

// 1. Update DashboardView.swift
let dashboardPath = path.join(__dirname, '..', 'Gaurex', 'Views', 'Dashboard', 'DashboardView.swift');
let dashboardContent = fs.readFileSync(dashboardPath, 'utf8');

// Replace top header GAUREX with animated sparkle orb
const oldHeader = `                                HStack(spacing: 0) {
                                    Text("G")
                                        .font(.pjs(24, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    Text("A")
                                        .font(.pjs(24, weight: .black))
                                        .foregroundColor(goldAccent)
                                    Text("UREX")
                                        .font(.pjs(24, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                }
                                .tracking(2.0)`;

const newHeader = `                                HStack(spacing: 8) {
                                    HStack(spacing: 0) {
                                        Text("G")
                                            .font(.pjs(24, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                        Text("A")
                                            .font(.pjs(24, weight: .black))
                                            .foregroundColor(goldAccent)
                                        Text("UREX")
                                            .font(.pjs(24, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    }
                                    .tracking(2.0)
                                    
                                    // Animated AI Sparkles
                                    ZStack {
                                        Circle()
                                            .fill(deepPurple)
                                            .frame(width: 22, height: 22)
                                            .overlay(Circle().stroke(goldAccent.opacity(0.8), lineWidth: 1))
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(goldAccent)
                                            .rotationEffect(.degrees(sparklinePulse ? 180 : 0))
                                            .scaleEffect(sparklinePulse ? 1.15 : 0.90)
                                    }
                                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: sparklinePulse)
                                }`;

// Replace Revenue Card subtitle with Live Inflow & Expenses Breakdown
const oldRevenueSubtitle = `                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 11, weight: .bold))
                                            Text("Verified Cash")
                                                .font(.pjs(12, weight: .bold))
                                            Text("• \\(store.invoices.filter { $0.status == .paid }.count) Settled Invoices")
                                                .font(.pjs(11, weight: .regular))
                                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                        }
                                        .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))`;

const newRevenueSubtitle = `                                        HStack(spacing: 8) {
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
                                        }`;

// Quick actions 6-grid
const oldQuickActions = `                                // 4. AI Assistant
                                QuickActionCardTile(
                                    icon: "brain.head.profile",
                                    iconColor: goldAccent,
                                    title: "AI Assistant",
                                    subtitle: "Ask NEO advisor"
                                ) {
                                    selectedTab = .aiModel
                                }
                            }`;

const newQuickActions = `                                // 4. AI Assistant
                                QuickActionCardTile(
                                    icon: "brain.head.profile",
                                    iconColor: goldAccent,
                                    title: "AI Assistant",
                                    subtitle: "Ask NEO advisor"
                                ) {
                                    selectedTab = .aiModel
                                }
                                
                                // 5. Log Expense
                                QuickActionCardTile(
                                    icon: "creditcard.fill",
                                    iconColor: Color(red: 0.92, green: 0.28, blue: 0.28),
                                    title: "Log Expense",
                                    subtitle: "Deducts live cashflow"
                                ) {
                                    showingAddExpenseSheet = true
                                }
                                
                                // 6. Profit Center
                                QuickActionCardTile(
                                    icon: "chart.line.uptrend.xyaxis",
                                    iconColor: goldAccent,
                                    title: "Profit Center",
                                    subtitle: "P&L and margins"
                                ) {
                                    showingProfitCenter = true
                                }
                            }`;

// Sheet presentation
const oldSheets = `.sheet(isPresented: $showingNewProjectSheet) {
                AddEditPackageView()
            }`;

const newSheets = `.sheet(isPresented: $showingNewProjectSheet) {
                AddEditPackageView()
            }
            .sheet(isPresented: $showingAddExpenseSheet) {
                AddExpenseSheet()
            }`;

// Standardize CRLF to LF for reliable matching
let normalized = dashboardContent.replace(/\r\n/g, '\n');
normalized = normalized.replace(oldHeader, newHeader);
normalized = normalized.replace(oldRevenueSubtitle, newRevenueSubtitle);
normalized = normalized.replace(oldQuickActions, newQuickActions);
normalized = normalized.replace(oldSheets, newSheets);

// Increase bezel padding from 20 to 24 in DashboardView
normalized = normalized.replace(/\.padding\(\.horizontal,\s*20\)/g, '.padding(.horizontal, 24)');

fs.writeFileSync(dashboardPath, normalized, 'utf8');
console.log('DashboardView.swift successfully updated!');

// 2. Increase bezel padding from 20 to 24 across other Views
const viewsDir = path.join(__dirname, '..', 'Gaurex', 'Views');

function processDir(dir) {
    const files = fs.readdirSync(dir);
    for (const f of files) {
        const fullPath = path.join(dir, f);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
            processDir(fullPath);
        } else if (f.endsWith('.swift')) {
            let content = fs.readFileSync(fullPath, 'utf8');
            if (content.includes('.padding(.horizontal, 20)')) {
                let updated = content.replace(/\.padding\(\.horizontal,\s*20\)/g, '.padding(.horizontal, 24)');
                fs.writeFileSync(fullPath, updated, 'utf8');
                console.log(`Updated bezel padding in: ${f}`);
            }
        }
    }
}

processDir(viewsDir);
console.log('All view horizontal bezel paddings expanded to 24pt successfully!');
