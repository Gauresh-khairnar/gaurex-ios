//
//  ClientsListView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Pixel-Perfect Executive Clients & CRM Management Screen
//

import SwiftUI

public struct ClientsListView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var searchText: String = ""
    @State private var selectedStatusFilter: ClientStatus? = nil
    @State private var showingAddSheet = false
    @State private var clientToDelete: Client? = nil
    @State private var showingDeleteClientAlert = false
    @State private var sortOption: ClientSortOption = .newest
    
    // Animation states
    @State private var animateHeader = false
    @State private var animateStats = false
    @State private var animateList = false
    
    public enum ClientSortOption: String, CaseIterable, Identifiable {
        case newest = "Recent"
        case name = "Name (A-Z)"
        case revenue = "Highest Revenue"
        case outstanding = "Highest Outstanding"
        public var id: String { rawValue }
    }
    
    public init() {}
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    private let mistGray = Color.gaurexMistGray
    
    public var filteredClients: [Client] {
        var list = store.clients
        if !searchText.isEmpty {
            list = list.filter { client in
                client.name.localizedCaseInsensitiveContains(searchText) ||
                client.companyName.localizedCaseInsensitiveContains(searchText) ||
                client.email.localizedCaseInsensitiveContains(searchText) ||
                client.phone.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let filter = selectedStatusFilter {
            list = list.filter { $0.status == filter }
        }
        switch sortOption {
        case .newest: list.sort { $0.createdAt > $1.createdAt }
        case .name: list.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .revenue: list.sort { $0.totalCollected > $1.totalCollected }
        case .outstanding: list.sort { $0.outstandingBalance > $1.outstandingBalance }
        }
        return list
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? Color(red: 0.07, green: 0.07, blue: 0.09) : Color(red: 0.96, green: 0.96, blue: 0.98))
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // MARK: - Top Header (GAUREX + Bell + Avatar)
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 1) {
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
                                
                                Text("Executive Dashboard")
                                    .font(.pjs(13, weight: .regular))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            
                            Spacer()
                            
                            // Bell Notifications
                            ZStack(alignment: .topTrailing) {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.22) : Color.white)
                                    .frame(width: 40, height: 40)
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                                
                                Image(systemName: "bell")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    .frame(width: 40, height: 40)
                                
                                Circle()
                                    .fill(goldAccent)
                                    .frame(width: 8, height: 8)
                                    .offset(x: -6, y: 8)
                            }
                            
                            // Founder GK Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                deepPurple,
                                                Color(red: 0.14, green: 0.07, blue: 0.22)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 40, height: 40)
                                    .overlay(Circle().stroke(goldAccent.opacity(0.3), lineWidth: 1))
                                
                                Text("GK")
                                    .font(.pjs(14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // MARK: - Section Header Title + "+ Add Client"
                        HStack(alignment: .center) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(deepPurple)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Clients")
                                        .font(.pjs(22, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    Text("Manage your clients, packages and invoices all in one place.")
                                        .font(.pjs(11.5, weight: .regular))
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                showingAddSheet = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .bold))
                                    Text("Add Client")
                                        .font(.pjs(12.5, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(deepPurple)
                                .clipShape(Capsule())
                                .shadow(color: deepPurple.opacity(0.25), radius: 6, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - Search Bar with Filter Icon
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(uiColor: .tertiaryLabel))
                                .font(.system(size: 15))
                            
                            TextField("Search client by name, email or phone...", text: $searchText)
                                .font(.system(size: 13.5))
                                .textFieldStyle(.plain)
                            
                            if !searchText.isEmpty {
                                Button { searchText = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                            
                            Menu {
                                Picker("Sort Clients", selection: $sortOption) {
                                    ForEach(ClientSortOption.allCases) { opt in
                                        Text(opt.rawValue).tag(opt)
                                    }
                                }
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 6, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                        )
                        .padding(.horizontal, 20)
                        
                        // MARK: - Filter Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterPillButton(
                                    title: "All (\(store.clients.count))",
                                    isSelected: selectedStatusFilter == nil
                                ) {
                                    selectedStatusFilter = nil
                                }
                                
                                FilterPillButton(
                                    title: "Active (\(store.clients.filter { $0.status == .active }.count))",
                                    isSelected: selectedStatusFilter == .active
                                ) {
                                    selectedStatusFilter = .active
                                }
                                
                                FilterPillButton(
                                    title: "Pending (\(store.clients.filter { $0.status == .prospective }.count))",
                                    isSelected: selectedStatusFilter == .prospective
                                ) {
                                    selectedStatusFilter = .prospective
                                }
                                
                                FilterPillButton(
                                    title: "Inactive (\(store.clients.filter { $0.status == .archived }.count))",
                                    isSelected: selectedStatusFilter == .archived
                                ) {
                                    selectedStatusFilter = .archived
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - 4 Stats Cards (2x2 Spacious with Real Data)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            ClientStatCard(
                                icon: "person.2",
                                title: "Total Clients",
                                value: "\(store.clients.count)",
                                trend: "\(store.clients.filter { $0.status == .active }.count) Active",
                                isPositive: true,
                                isNeutral: false
                            )
                            
                            ClientStatCard(
                                icon: "shippingbox",
                                title: "Active Packages",
                                value: "\(store.packages.count)",
                                trend: "Verified",
                                isPositive: true,
                                isNeutral: false
                            )
                            
                            ClientStatCard(
                                icon: "indianrupeesign",
                                title: "Total Revenue",
                                value: FinancialCalculator.shared.formatCurrency(store.revenueCollected, symbol: store.settings.currencySymbol),
                                trend: "\(store.invoices.filter { $0.status == .paid }.count) Settled",
                                isPositive: true,
                                isNeutral: false
                            )
                            
                            ClientStatCard(
                                icon: "clock",
                                title: "Pending Invoices",
                                value: "\(store.overdueInvoicesCount)",
                                trend: store.overdueInvoicesCount > 0 ? "Due" : "Clear",
                                isPositive: store.overdueInvoicesCount == 0,
                                isNeutral: store.overdueInvoicesCount > 0
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - All Clients Header & List
                        HStack {
                            Text("All Clients (\(filteredClients.count))")
                                .font(.pjs(15, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            Spacer()
                            Menu {
                                Picker("Sort", selection: $sortOption) {
                                    ForEach(ClientSortOption.allCases) { opt in
                                        Text(opt.rawValue).tag(opt)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Sort: \(sortOption.rawValue)")
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10))
                                }
                                .font(.pjs(12, weight: .semibold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Client List Rows matching screenshot
                        VStack(spacing: 12) {
                            ForEach(filteredClients) { client in
                                NavigationLink {
                                    ClientDetailView(client: client)
                                } label: {
                                    ClientImageMatchRow(client: client) {
                                        clientToDelete = client
                                        showingDeleteClientAlert = true
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 110)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddSheet) {
                AddEditClientView()
            }
            .confirmationDialog("Delete Client Permanently?", isPresented: $showingDeleteClientAlert, titleVisibility: .visible) {
                Button("Delete Client Permanently", role: .destructive) {
                    if let c = clientToDelete {
                        withAnimation {
                            store.deleteClient(id: c.id)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to permanently delete '\(clientToDelete?.name ?? "this client")'? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Client Image Match UI Components

private struct FilterPillButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let deepPurple = Color(red: 0.18, green: 0.08, blue: 0.28)
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : Color(uiColor: .secondaryLabel))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? deepPurple : (colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.20) : Color.white))
                        .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.03), radius: 4, x: 0, y: 1)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.black.opacity(0.04), lineWidth: 0.8)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct ClientStatCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let title: String
    let value: String
    let trend: String
    let isPositive: Bool
    let isNeutral: Bool
    
    private let deepPurple = Color(red: 0.18, green: 0.08, blue: 0.28)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0.24, green: 0.12, blue: 0.36).opacity(0.08))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(deepPurple)
                    )
                
                Spacer()
                
                HStack(spacing: 3) {
                    if isNeutral {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .bold))
                        Text(trend)
                            .font(.system(size: 10.5, weight: .bold))
                    } else {
                        Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                            .font(.system(size: 9, weight: .bold))
                        Text(trend)
                            .font(.system(size: 10.5, weight: .bold))
                    }
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    (isNeutral ? Color.secondary : (isPositive ? Color(red: 0.06, green: 0.72, blue: 0.44) : Color.red)).opacity(0.12)
                )
                .clipShape(Capsule())
                .foregroundColor(
                    isNeutral
                        ? Color(uiColor: .secondaryLabel)
                        : (isPositive ? Color(red: 0.06, green: 0.72, blue: 0.44) : Color.red)
                )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .lineLimit(1)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
        )
    }
}

private struct ClientImageMatchRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let client: Client
    let onDelete: () -> Void
    
    private let deepPurple = Color(red: 0.18, green: 0.08, blue: 0.28)
    
    var body: some View {
        HStack(spacing: 14) {
            // Circle Logo / Initial
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.12, blue: 0.32),
                            Color(red: 0.14, green: 0.06, blue: 0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 46, height: 46)
                .overlay(
                    Text(String(client.name.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // Name + Category Badge + Contact
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(client.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                    
                    Text(client.businessCategory.isEmpty ? "Business" : client.businessCategory)
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundColor(deepPurple)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(deepPurple.opacity(0.08))
                        .clipShape(Capsule())
                }
                
                Text(client.phone.isEmpty ? "+91 98765 43210" : client.phone)
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                
                Text(client.email.isEmpty ? "hello@\(client.name.lowercased().replacingOccurrences(of: " ", with: "")).com" : client.email)
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
            
            Spacer()
            
            // Package Tag + Status Pill + Chevron
            VStack(alignment: .trailing, spacing: 5) {
                Text(client.packageIds.isEmpty ? "Premium Package" : "Enterprise")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                
                HStack(spacing: 6) {
                    // Status Pill
                    Text(client.status == .active ? "Active" : (client.status == .prospective ? "Pending" : "Inactive"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(client.status == .active ? Color(red: 0.06, green: 0.72, blue: 0.44) : (client.status == .prospective ? Color.orange : Color.gray))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            (client.status == .active ? Color(red: 0.06, green: 0.72, blue: 0.44) : (client.status == .prospective ? Color.orange : Color.gray)).opacity(0.12)
                        )
                        .clipShape(Capsule())
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
        )
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete Client", systemImage: "trash")
            }
        }
    }
}
