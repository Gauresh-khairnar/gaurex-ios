//
//  PackageManagementView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct PackageManagementView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @State private var showingAddSheet = false
    @State private var selectedPackage: ServicePackage? = nil
    @State private var packageToDelete: ServicePackage? = nil
    @State private var showingDeletePackageAlert = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("CATALOG PACKAGES")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    if store.packages.isEmpty {
                        EmptyStateView(
                            icon: "shippingbox",
                            title: "No Packages Defined",
                            description: "Add commercial offerings, enterprise software packages, and retainers.",
                            actionTitle: "Add Package"
                        ) {
                            showingAddSheet = true
                        }
                    } else {
                        VStack(spacing: 10) {
                            ForEach(store.packages) { pkg in
                                NavigationLink {
                                    AddEditPackageView(packageToEdit: pkg)
                                } label: {
                                    GlassCard(padding: 14) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(pkg.name)
                                                        .font(.system(size: 15, weight: .bold))
                                                    Text(pkg.category.rawValue)
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                VStack(alignment: .trailing, spacing: 2) {
                                                    Text(FinancialCalculator.shared.formatCurrency(pkg.basePrice))
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(theme.accentColor)
                                                    Text(pkg.billingType.rawValue)
                                                        .font(.system(size: 10))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            
                                            Text(pkg.description)
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                                .padding(.top, 2)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        packageToDelete = pkg
                                        showingDeletePackageAlert = true
                                    } label: {
                                        Label("Delete Package", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer().frame(height: 80)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Package Catalog")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditPackageView()
        }
        .confirmationDialog("Delete Package?", isPresented: $showingDeletePackageAlert, titleVisibility: .visible) {
            Button("Delete Package", role: .destructive) {
                if let p = packageToDelete {
                    withAnimation {
                        store.deletePackage(id: p.id)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to permanently delete '\(packageToDelete?.name ?? "this package")'?")
        }
    }
}

public struct AddEditPackageView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    
    public var packageToEdit: BusinessPackage?
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var category: PackageCategory = .softwareDevelopment
    @State private var basePrice: Double = 100000.0
    @State private var billingType: BillingType = .oneTime
    @State private var isTaxable: Bool = true
    @State private var taxRate: Double = 18.0
    @State private var isActive: Bool = true
    @State private var featuresText: String = ""
    @State private var deliverablesText: String = ""
    
    public init(packageToEdit: BusinessPackage? = nil) {
        self.packageToEdit = packageToEdit
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Package Specifications")) {
                    TextField("Package Name *", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(PackageCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    Picker("Billing Structure", selection: $billingType) {
                        ForEach(BillingType.allCases) { bt in
                            Text(bt.rawValue).tag(bt)
                        }
                    }
                    HStack {
                        Text("Base Price (₹) *")
                        Spacer()
                        TextField("0", value: $basePrice, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("Active for New Invoices", isOn: $isActive)
                }
                
                Section(header: Text("Overview & Commercial Scope")) {
                    TextField("Brief Description", text: $description)
                }
                
                Section(header: Text("Features (Comma-separated)")) {
                    TextField("e.g. Microservices, Admin Panel, iOS App", text: $featuresText)
                }
                
                Section(header: Text("Deliverables (Comma-separated)")) {
                    TextField("e.g. Source Code, Docker Container, CI/CD", text: $deliverablesText)
                }
            }
            .navigationTitle(packageToEdit == nil ? "New Package" : "Edit Package")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePackage()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                if let p = packageToEdit {
                    name = p.name
                    description = p.description
                    category = p.category
                    basePrice = p.basePrice
                    billingType = p.billingType
                    isTaxable = p.isTaxable
                    taxRate = p.taxRate
                    isActive = p.isActive
                    featuresText = p.features.joined(separator: ", ")
                    deliverablesText = p.deliverables.joined(separator: ", ")
                }
            }
        }
    }
    
    private func savePackage() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let feat = featuresText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let deliv = deliverablesText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        if let existing = packageToEdit {
            var updated = existing
            updated.name = name
            updated.description = description
            updated.category = category
            updated.basePrice = basePrice
            updated.billingType = billingType
            updated.isTaxable = isTaxable
            updated.taxRate = taxRate
            updated.isActive = isActive
            updated.features = feat
            updated.deliverables = deliv
            updated.updatedAt = Date()
            store.updatePackage(updated)
        } else {
            let newPkg = BusinessPackage(
                name: name,
                description: description,
                category: category,
                basePrice: basePrice,
                billingType: billingType,
                features: feat,
                deliverables: deliv,
                isTaxable: isTaxable,
                taxRate: taxRate,
                isActive: isActive
            )
            store.addPackage(newPkg)
        }
        dismiss()
    }
}
