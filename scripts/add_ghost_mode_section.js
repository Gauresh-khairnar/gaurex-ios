const fs = require('fs');
const path = require('path');

const settingsPath = path.join(__dirname, '..', 'Gaurex', 'Views', 'Settings', 'SettingsView.swift');
let content = fs.readFileSync(settingsPath, 'utf8').replace(/\r\n/g, '\n');

// 1. Add state variable
const oldState = `@State private var showingResetAlert: Bool = false`;
const newState = `@State private var showingResetAlert: Bool = false
    @State private var showingGhostSimulatorSheet: Bool = false`;

if (!content.includes('showingGhostSimulatorSheet')) {
    content = content.replace(oldState, newState);
}

// 2. Add Ghost Mode Section right before SYSTEM & SUPPORT
const targetSection = `                        // MARK: - System & Support Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SYSTEM & SUPPORT")`;

const ghostSection = `                        // MARK: - Ghost Mode & Executive Privacy Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("GHOST MODE & STEALTH PRIVACY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                // 1. Ghost Stealth Mode Toggle
                                HStack(spacing: 14) {
                                    Image(systemName: store.isStealthPrivacyActive ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(store.isStealthPrivacyActive ? .red : Color.gaurexDeepPlum)
                                        .frame(width: 32, height: 32)
                                        .background((store.isStealthPrivacyActive ? Color.red : Color.gaurexDeepPlum).opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Ghost Stealth Mode")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Text(store.isStealthPrivacyActive ? "Numbers hidden behind frosted shield" : "Tap to disguise all ledger balances")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $store.isStealthPrivacyActive)
                                        .labelsHidden()
                                        .tint(Color.gaurexWarmGold)
                                        .onChange(of: store.isStealthPrivacyActive) { _ in
                                            MotionTokens.impact(style: .medium)
                                        }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                
                                Divider().padding(.leading, 56)
                                
                                // 2. Ghost Runway Simulator Quick Access
                                Button {
                                    showingGhostSimulatorSheet = true
                                    MotionTokens.selection()
                                } label: {
                                    SettingsRow(
                                        icon: "wand.and.stars",
                                        iconColor: .orange,
                                        title: "Ghost Runway Simulator",
                                        subtitle: "Run what-if strategic business war games",
                                        badgeText: "War Games"
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                            )
                            .padding(.horizontal, 24)
                        }
                        
` + targetSection;

if (!content.includes('GHOST MODE & STEALTH PRIVACY')) {
    content = content.replace(targetSection, ghostSection);
}

// 3. Add sheet presentation for GhostRunwaySimulatorSheet
const targetAlert = `.alert("Reset to Clean Slate?", isPresented: $showingResetAlert) {`;
const sheetWithAlert = `.sheet(isPresented: $showingGhostSimulatorSheet) {
                GhostRunwaySimulatorSheet()
            }
            ` + targetAlert;

if (!content.includes('showingGhostSimulatorSheet) {')) {
    content = content.replace(targetAlert, sheetWithAlert);
}

fs.writeFileSync(settingsPath, content, 'utf8');
console.log('SettingsView.swift successfully upgraded with Ghost Mode Section!');
