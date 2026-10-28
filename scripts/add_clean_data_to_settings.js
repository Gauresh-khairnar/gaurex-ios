const fs = require('fs');
const path = require('path');

const settingsPath = path.join(__dirname, '..', 'Gaurex', 'Views', 'Settings', 'SettingsView.swift');
let content = fs.readFileSync(settingsPath, 'utf8').replace(/\r\n/g, '\n');

// 1. Add state variable
const targetState = `@State private var companyName: String = "GAUREX"`;
const replacementState = `@State private var companyName: String = "GAUREX"
    @State private var showingResetAlert: Bool = false`;

content = content.replace(targetState, replacementState);

// 2. Add button in DATA & BACKUP section
const targetBackup = `                                Button {
                                    exportBusinessData()
                                    MotionTokens.selection()
                                } label: {
                                    SettingsRow(
                                        icon: "square.and.arrow.up.fill",
                                        iconColor: .blue,
                                        title: "Data & Backup",
                                        subtitle: "Export full business JSON ledger snapshot"
                                    )
                                }
                                .buttonStyle(.plain)`;

const replacementBackup = `                                Button {
                                    exportBusinessData()
                                    MotionTokens.selection()
                                } label: {
                                    SettingsRow(
                                        icon: "square.and.arrow.up.fill",
                                        iconColor: .blue,
                                        title: "Data & Backup",
                                        subtitle: "Export full business JSON ledger snapshot"
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                Divider().padding(.leading, 56)
                                
                                Button {
                                    showingResetAlert = true
                                } label: {
                                    SettingsRow(
                                        icon: "trash.fill",
                                        iconColor: .red,
                                        title: "Clear All Previous Data",
                                        subtitle: "Purge all test/mock records for clean production use",
                                        badgeText: "Clean Slate"
                                    )
                                }
                                .buttonStyle(.plain)`;

content = content.replace(targetBackup, replacementBackup);

// 3. Add alert at end of view before closing brace
const alertCode = `            .alert("Reset to Clean Slate?", isPresented: $showingResetAlert) {
                Button("Delete All Previous Data", role: .destructive) {
                    store.clearAllOperationalData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently clear all previous mock/test clients, invoices, payments, and tasks, leaving GAUREX completely clean for your real business operations.")
            }
        }`;

// Find last `        }` of the body
const bodyEnd = `            .sheet(isPresented: $showingExportShare) {
                ShareSheet(items: [backupFileURL].compactMap { $0 })
            }
        }`;

const replacementBodyEnd = `            .sheet(isPresented: $showingExportShare) {
                ShareSheet(items: [backupFileURL].compactMap { $0 })
            }
` + alertCode;

content = content.replace(bodyEnd, replacementBodyEnd);

fs.writeFileSync(settingsPath, content, 'utf8');
console.log('SettingsView.swift successfully updated with Clear Data option and alert!');
