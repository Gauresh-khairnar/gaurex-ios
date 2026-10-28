//
//  ClientRelationshipOrbitView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Interactive Client Relationship Orbit (3D Solar System View)
//

import SwiftUI

public struct ClientRelationshipOrbitView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedClient: Client? = nil
    @State private var orbitalPhase: Double = 0.0
    @State private var isAutoRotating: Bool = true
    @State private var dragOffsetAngle: Double = 0.0
    @State private var coronaPulse: Bool = false
    @State private var showingWhatsAppSheet: Bool = false
    @State private var clientForWhatsApp: Client? = nil
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2.0, y: geometry.size.height * 0.42)
            let maxRadius = min(geometry.size.width, geometry.size.height) * 0.44
            
            ZStack {
                backgroundGalaxy(maxRadius: maxRadius)
                orbitRings(center: center, maxRadius: maxRadius)
                centralNucleus(center: center)
                planetsOverlay(center: center, maxRadius: maxRadius)
                controlsOverlay
                dossierCardOverlay
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffsetAngle = Double(value.translation.width) * 0.008
                    }
                    .onEnded { value in
                        orbitalPhase += dragOffsetAngle
                        dragOffsetAngle = 0
                    }
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                coronaPulse = true
            }
            startOrbitTimer()
        }
        .sheet(isPresented: $showingWhatsAppSheet) {
            whatsappSheetContent
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func backgroundGalaxy(maxRadius: CGFloat) -> some View {
        RadialGradient(
            gradient: Gradient(colors: [
                deepPurple.opacity(colorScheme == .dark ? 0.35 : 0.08),
                Color.clear
            ]),
            center: .init(x: 0.5, y: 0.42),
            startRadius: 20,
            endRadius: maxRadius * 1.2
        )
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func orbitRings(center: CGPoint, maxRadius: CGFloat) -> some View {
        OrbitTrackView(
            center: center,
            radius: maxRadius * 0.38,
            label: "Settled / Low (≤₹10k)",
            color: goldAccent.opacity(0.35)
        )
        OrbitTrackView(
            center: center,
            radius: maxRadius * 0.68,
            label: "Receivable (₹10k-₹50k)",
            color: goldAccent.opacity(0.25)
        )
        OrbitTrackView(
            center: center,
            radius: maxRadius * 0.98,
            label: "High Priority (>₹50k)",
            color: deepPurple.opacity(0.40)
        )
    }
    
    @ViewBuilder
    private func centralNucleus(center: CGPoint) -> some View {
        ZStack {
            Circle()
                .fill(goldAccent.opacity(0.18))
                .frame(width: 86, height: 86)
                .scaleEffect(coronaPulse ? 1.25 : 0.95)
                .opacity(coronaPulse ? 0.3 : 0.7)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [deepPurple, Color(red: 0.12, green: 0.04, blue: 0.16)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)
                .overlay(Circle().stroke(goldAccent, lineWidth: 2.0))
                .shadow(color: goldAccent.opacity(0.6), radius: 14, x: 0, y: 0)
            
            VStack(spacing: 2) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(goldAccent)
                
                Text("GAUREX")
                    .font(.pjs(8.5, weight: .black))
                    .tracking(1.4)
                    .foregroundColor(.white)
            }
        }
        .position(center)
        .onTapGesture {
            MotionTokens.impact(style: .light)
            withAnimation(MotionTokens.snappySpring) {
                selectedClient = nil
            }
        }
    }
    
    @ViewBuilder
    private func planetsOverlay(center: CGPoint, maxRadius: CGFloat) -> some View {
        if store.clients.isEmpty {
            VStack(spacing: 6) {
                Image(systemName: "globe.asia.australia.fill")
                    .font(.system(size: 32))
                    .foregroundColor(goldAccent.opacity(0.6))
                Text("No Clients in Orbit")
                    .font(.pjs(14, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                Text("Add clients to populate your solar system.")
                    .font(.pjs(11.5, weight: .regular))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
            .position(x: center.x, y: center.y + 110)
        } else {
            ForEach(Array(store.clients.enumerated()), id: \.element.id) { index, client in
                OrbitingPlanetNodeView(
                    client: client,
                    index: index,
                    totalCount: store.clients.count,
                    center: center,
                    maxRadius: maxRadius,
                    orbitalPhase: orbitalPhase,
                    dragOffsetAngle: dragOffsetAngle,
                    isSelected: selectedClient?.id == client.id,
                    onSelect: {
                        if selectedClient?.id == client.id {
                            selectedClient = nil
                        } else {
                            selectedClient = client
                        }
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private var controlsOverlay: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    MotionTokens.impact(style: .light)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isAutoRotating.toggle()
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: isAutoRotating ? "pause.fill" : "play.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text(isAutoRotating ? "Auto-Orbit" : "Paused")
                            .font(.pjs(10.5, weight: .bold))
                    }
                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.20) : Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    )
                }
                .padding(.trailing, 20)
            }
            Spacer()
        }
        .padding(.top, 10)
    }
    
    @ViewBuilder
    private var dossierCardOverlay: some View {
        if let client = selectedClient {
            VStack {
                Spacer()
                ExecutiveClientOrbitCard(
                    client: client,
                    currencySymbol: store.settings.currencySymbol,
                    onWhatsAppNudge: {
                        clientForWhatsApp = client
                        showingWhatsAppSheet = true
                    },
                    onDismiss: {
                        withAnimation(MotionTokens.snappySpring) {
                            selectedClient = nil
                        }
                    }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.92, anchor: .bottom).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                    removal: .scale(scale: 0.95, anchor: .bottom).combined(with: .opacity).combined(with: .move(edge: .bottom))
                ))
            }
        }
    }
    
    @ViewBuilder
    private var whatsappSheetContent: some View {
        if let client = clientForWhatsApp {
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "message.badge.filled.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color.green)
                    
                    Text("WhatsApp Executive Settler")
                        .font(.pjs(20, weight: .bold))
                    
                    Text("Send automated executive payment settlement reminder to \(client.name) for \(store.settings.currencySymbol)\(Int(client.outstandingBalance)).")
                        .font(.pjs(13, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .padding(.horizontal, 20)
                    
                    Button {
                        sendWhatsAppClientNudge(for: client)
                        showingWhatsAppSheet = false
                    } label: {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Dispatch via WhatsApp")
                                .font(.pjs(14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                }
                .padding(24)
                .presentationDetents([.fraction(0.38)])
            }
        }
    }
    
    private func startOrbitTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if isAutoRotating {
                orbitalPhase += 0.004
                if orbitalPhase >= 2.0 * .pi {
                    orbitalPhase = 0
                }
            }
        }
    }
    
    private func sendWhatsAppClientNudge(for client: Client) {
        let cleanPhone = client.phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "")
        let message = "Dear \(client.name), this is Gauresh Khairnar from GAUREX. A friendly executive reminder regarding your outstanding balance of \(store.settings.currencySymbol)\(Int(client.outstandingBalance)). Please let us know if you require any invoice or bank wire details. Thank you."
        guard let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = !cleanPhone.isEmpty ? "whatsapp://send?phone=\(cleanPhone)&text=\(encoded)" : "whatsapp://send?text=\(encoded)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let webUrl = URL(string: "https://api.whatsapp.com/send?text=\(encoded)") {
            UIApplication.shared.open(webUrl)
        }
    }
}

// MARK: - Concentric Orbit Track View
fileprivate struct OrbitTrackView: View {
    let center: CGPoint
    let radius: CGFloat
    let label: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 1.0, dash: [4, 4])
                )
                .frame(width: radius * 2, height: radius * 2)
                .position(center)
            
            Text(label)
                .font(.pjs(8.5, weight: .semibold))
                .foregroundColor(color)
                .position(x: center.x, y: center.y - radius - 8)
        }
    }
}

// MARK: - Orbiting Planet Node View (Modularized for Swift Compiler Performance)
fileprivate struct OrbitingPlanetNodeView: View {
    let client: Client
    let index: Int
    let totalCount: Int
    let center: CGPoint
    let maxRadius: CGFloat
    let orbitalPhase: Double
    let dragOffsetAngle: Double
    let isSelected: Bool
    let onSelect: () -> Void
    
    private var planetRadius: CGFloat {
        let outstanding = client.outstandingBalance
        if outstanding <= 500 {
            return maxRadius * 0.38
        } else if outstanding <= 25000 {
            let ratio = CGFloat(outstanding / 25000.0)
            return (maxRadius * 0.38) + (maxRadius * 0.30 * ratio)
        } else {
            let ratio = min(1.0, CGFloat((outstanding - 25000.0) / 75000.0))
            return (maxRadius * 0.68) + (maxRadius * 0.30 * ratio)
        }
    }
    
    private var planetSize: CGFloat {
        let total = client.totalInvoiced
        if total <= 10000 {
            return 28.0
        } else if total <= 50000 {
            return 36.0
        } else if total <= 150000 {
            return 44.0
        } else {
            return 52.0
        }
    }
    
    private var positionPoint: CGPoint {
        let baseAngle: Double = (Double(index) / Double(max(1, totalCount))) * 2.0 * .pi
        let angle: Double = baseAngle + orbitalPhase + dragOffsetAngle
        let x: CGFloat = center.x + CGFloat(cos(angle)) * planetRadius
        let y: CGFloat = center.y + CGFloat(sin(angle)) * planetRadius
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        ClientPlanetView(
            client: client,
            size: planetSize,
            isSelected: isSelected
        )
        .position(positionPoint)
        .onTapGesture {
            MotionTokens.impact(style: .medium)
            withAnimation(MotionTokens.snappySpring) {
                onSelect()
            }
        }
    }
}

// MARK: - Individual Client Planet View
fileprivate struct ClientPlanetView: View {
    let client: Client
    let size: CGFloat
    let isSelected: Bool
    
    private var planetGradient: LinearGradient {
        switch client.status {
        case .active:
            return LinearGradient(
                colors: [Color.gaurexWarmGold, Color(red: 0.20, green: 0.65, blue: 0.40)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .prospective, .onHold:
            return LinearGradient(
                colors: [Color.gaurexDeepPlum, Color(red: 0.95, green: 0.55, blue: 0.20)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .inactive, .completed, .archived:
            return LinearGradient(
                colors: [Color.gray, Color(red: 0.15, green: 0.18, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                if isSelected {
                    Circle()
                        .stroke(Color.gaurexWarmGold, lineWidth: 2.2)
                        .frame(width: size + 14, height: size + 14)
                        .shadow(color: Color.gaurexWarmGold.opacity(0.7), radius: 6, x: 0, y: 0)
                }
                
                Circle()
                    .fill(planetGradient)
                    .frame(width: size, height: size)
                    .shadow(color: Color.gaurexWarmGold.opacity(client.status == .active ? 0.4 : 0.1), radius: 6, x: 0, y: 2)
                
                Text(client.name.prefix(2).uppercased())
                    .font(.pjs(size * 0.34, weight: .black))
                    .foregroundColor(.white)
            }
            .scaleEffect(isSelected ? 1.18 : 1.0)
            
            Text(client.name)
                .font(.pjs(9.5, weight: .bold))
                .foregroundColor(isSelected ? Color.gaurexWarmGold : .primary)
                .lineLimit(1)
                .frame(maxWidth: 70)
        }
    }
}

// MARK: - Executive Floating Dossier Card (Ripplix / Wise Glass Style)
fileprivate struct ExecutiveClientOrbitCard: View {
    let client: Client
    let currencySymbol: String
    let onWhatsAppNudge: () -> Void
    let onDismiss: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(client.name)
                            .font(.pjs(17, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                        
                        Text(client.status.rawValue.capitalized)
                            .font(.pjs(9.5, weight: .bold))
                            .foregroundColor(client.status == .active ? .green : goldAccent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill((client.status == .active ? Color.green : goldAccent).opacity(0.15))
                            )
                    }
                    
                    if !client.companyName.isEmpty {
                        Text(client.companyName)
                            .font(.pjs(11.5, weight: .medium))
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .opacity(0.4)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOTAL CONTRACT")
                        .font(.pjs(9, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    
                    Text("\(currencySymbol)\(Int(client.totalInvoiced))")
                        .font(.pjs(16, weight: .black))
                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("OUTSTANDING")
                        .font(.pjs(9, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    
                    Text("\(currencySymbol)\(Int(client.outstandingBalance))")
                        .font(.pjs(16, weight: .black))
                        .foregroundColor(client.outstandingBalance > 0 ? Color.red : Color.green)
                }
            }
            
            HStack(spacing: 10) {
                NavigationLink(destination: ClientDetailView(client: client)) {
                    Text("View Dossier")
                        .font(.pjs(12, weight: .bold))
                        .foregroundColor(deepPurple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.12) : deepPurple.opacity(0.08))
                        )
                }
                
                if client.outstandingBalance > 0 {
                    Button(action: onWhatsAppNudge) {
                        HStack(spacing: 5) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text("WhatsApp Nudge")
                                .font(.pjs(12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.15, green: 0.75, blue: 0.38), Color(red: 0.10, green: 0.60, blue: 0.30)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 2)
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    colorScheme == .dark
                        ? Color(red: 0.14, green: 0.14, blue: 0.18).opacity(0.95)
                        : Color.white.opacity(0.96)
                )
                .shadow(color: Color.black.opacity(0.14), radius: 18, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(goldAccent.opacity(0.4), lineWidth: 1.2)
                )
        )
    }
}
