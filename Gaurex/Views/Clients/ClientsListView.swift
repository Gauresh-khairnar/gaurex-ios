//
//  ClientsListView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct ClientsListView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    @State private var searchText: String = ""
    @State private var selectedStatusFilter: ClientStatus? = nil
    @State private var showingAddSheet = false
    @State private var sortOption: ClientSortOption = .newest
    
    public enum ClientSortOption: String, CaseIterable, Identifiable {
        case newest = "Newest First"
        case name = "Name (A-Z)"
        case revenue = "Highest Revenue"
        case outstanding = "Highest Outstanding"
        public var id: String { rawValue }
    }
    
    public init() {}
    
    public var filteredClients: [Client] {
        var list = store.clients
        
        // Search filter
        if !searchText.isEmpty {
            list = list.filter { client in
                client.name.localizedCaseInsensitiveContains(searchText) ||
                client.companyName.localizedCaseInsensitiveContains(searchText) ||
                client.email.localizedCaseInsensitiveContains(searchText) ||
                client.phone.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Status filter
        if let filter = selectedStatusFilter {
            list = list.filter { $0.status == filter }
        }
        
        // Sorting
        switch sortOption {
        case .newest:
            list.sort { $0.createdAt > $1.createdAt }
        case .name:
            list.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .revenue:
            list.sort { $0.totalCollected > $1.totalCollected }
        case .outstanding:
            list.sort { $0.outstandingBalance > $1.outstandingBalance }
        }
        
        return list
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search & Filter Header
                    VStack(spacing: 12) {
                        // Search Field
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Search clients, company, email, phone...", text: $searchText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 14))
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(10)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.glassBorderColor, lineWidth: 1))
                        .padding(.horizontal, 16)
                        
                        // Status Filter Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(title: "All (\(store.clients.count))", isSelected: selectedStatusFilter == nil) {
                                    selectedStatusFilter = nil
                                }
                                ForEach(ClientStatus.allCases) { status in
                                    let count = store.clients.filter { $0.status == status }.count
                                    FilterChip(title: "\(status.rawValue) (\(count))", isSelected: selectedStatusFilter == status) {
                                        selectedStatusFilter = status
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    
                    // Main Content
                    if filteredClients.isEmpty {
                        EmptyStateView(
                            icon: "person.crop.rectangle.stack",
                            title: searchText.isEmpty ? "No Clients Registered" : "No Matching Clients",
                            description: searchText.isEmpty
                                ? "Register your enterprise clients to manage contracts, packages, and invoices."
                                : "No client records match your current search query.",
                            actionTitle: searchText.isEmpty ? "Add First Client" : nil
                        ) {
                            showingAddSheet = true
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredClients) { client in
                                    NavigationLink {
                                        ClientDetailView(client: client)
                                    } label: {
                                        ClientCardView(client: client)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            Spacer().frame(height: 80)
                        }
                    }
                }
            }
            .navigationTitle("Clients")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            ForEach(ClientSortOption.allCases) { opt in
                                Text(opt.rawValue).tag(opt)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditClientView()
            }
        }
    }
}

public struct FilterChip: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var title: String
    public var isSelected: Bool
    public var action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    if isSelected {
                        Capsule().fill(Color.primary)
                    } else {
                        Capsule().fill(theme.cardBackground).overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

public struct ClientCardView: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var client: Client
    
    public var body: some View {
        GlassCard(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(client.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if !client.companyName.isEmpty {
                            Text(client.companyName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    StatusBadge(
                        text: client.status.rawValue,
                        color: client.status == .active ? .green : (client.status == .prospective ? .orange : .gray)
                    )
                }
                
                Divider().background(theme.glassBorderColor)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TOTAL COLLECTED")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(FinancialCalculator.shared.formatCurrency(client.totalCollected))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("BALANCE DUE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(FinancialCalculator.shared.formatCurrency(client.outstandingBalance))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(client.outstandingBalance > 0 ? .orange : .secondary)
                    }
                }
            }
        }
    }
}
