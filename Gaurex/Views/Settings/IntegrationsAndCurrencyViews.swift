//
//  IntegrationsAndCurrencyViews.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct IntegrationsHubView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("ENTERPRISE INTEGRATIONS")
                                        .font(TypographyTokens.sectionHeader)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    OwnerBadge()
                                }
                                Text("Connect authorized corporate communication, scheduling, and payment infrastructure. All tokens are encrypted using iOS Keychain.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Text("ACTIVE PROVIDERS (\(store.integrations.count))")
                            .font(TypographyTokens.sectionHeader)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 8) {
                            ForEach(store.integrations) { item in
                                GlassCard(padding: 12) {
                                    HStack(spacing: 12) {
                                        Image(systemName: item.provider.icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(item.isConnected ? .green : .secondary)
                                            .frame(width: 38, height: 38)
                                            .background((item.isConnected ? Color.green : Color.secondary).opacity(0.12))
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.provider.rawValue)
                                                .font(.system(size: 14, weight: .semibold))
                                            Text(item.statusDescription)
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        StatusBadge(
                                            text: item.isConnected ? "CONNECTED" : "INACTIVE",
                                            color: item.isConnected ? .green : .gray
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer().frame(height: 60)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Integrations Hub")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
        }
    }
}

public struct MultiCurrencySettingsView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let sampleRates: [(SupportedCurrency, Double)] = [
        (.inr, 1.0),
        (.usd, 83.50),
        (.aed, 22.73),
        (.gbp, 106.20),
        (.eur, 90.80)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Executive Reporting Currency")) {
                    Picker("Reporting Currency", selection: $store.activeCurrency) {
                        ForEach(SupportedCurrency.allCases) { cur in
                            Text("\(cur.symbol) \(cur.displayName)").tag(cur)
                        }
                    }
                    
                    Text("Original currency is permanently preserved on all individual invoices and ledgers. Converted reporting values use effective exchange rates.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Exchange Rate Benchmark (Base INR ₹)")) {
                    ForEach(sampleRates, id: \.0) { cur, rate in
                        HStack {
                            Text("1 \(cur.rawValue)")
                                .font(.system(size: 13, weight: .semibold))
                            Spacer()
                            Text("₹\(String(format: "%.2f", rate))")
                                .font(TypographyTokens.code)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Multi-Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
        }
    }
}
