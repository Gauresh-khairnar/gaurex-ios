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
    private let mistGray = Color.gaurexMistGray
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2.0, y: geometry.size.height * 0.42)
            let maxRadius = min(geometry.size.width, geometry.size.height) * 0.44
            
            ZStack {
                // Background Galaxy / Starfield Glow
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
                
                // MARK: - Concentric Gravitational Orbit Rings
                Group {
                    // Inner Orbit (Settled / Low Balance: 0 - 10k)
                    OrbitTrackView(
                        center: center,
                        radius: maxRadius * 0.38,
                        label: "Settled / Low (≤₹10k)",
                        color: goldAccent.opacity(0.35)
                    )
                    
                    // Mid Orbit (Active Receivables: 10k - 50k)
                    OrbitTrackView(
                        center: center,
                        radius: maxRadius * 0.68,
                        label: "Receivable (₹10k-₹50k)",
                        color: goldAccent.opacity(0.25)
                    )
                    
                    // Outer Orbit (High Priority Collection: >50k)
                    OrbitTrackView(
                        center: center,
                        radius: maxRadius * 0.98,
                        label: "High Priority (>₹50k)",
                        color: deepPurple.opacity(0.40)
                    )
                }
                
                // MARK: - Central GAUREX Nucleus
                ZStack {
                    // Pulsing Corona
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
                
                // MARK: - Orbiting Client Planets
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
                        let planetRadius = calculateOrbitRadius(for: client, maxRadius: maxRadius)
                        let baseAngle = (Double(index) / Double(max(1, store.clients.count))) * 2.0 * .pi
                        let currentAngle = baseAngle + orbitalPhase + dragOffsetAngle
                        
                        let posX = center.x + CGFloat(cos(currentAngle)) * planetRadius
                        let posY = center.y + CGFloat(sin(currentAngle)) * planetRadius
                        let isSelected = selectedClient?.id == client.id
                        let planetSize = calculatePlanetSize(for: client)
                        
                        ClientPlanetView(
                            client: client,
                            size: planetSize,
                            isSelected: isSelected
                        )
                        .position(x: posX, y: posY)
                        .onTapGesture {
                            MotionTokens.impact(style: .medium)
                            withAnimation(MotionTokens.bouncySpring) {
                                if selectedClient?.id == client.id {
                                    selectedClient = nil
                                } else {
                                    selectedClient = client
                                }
                            }
                        }
                    }
                }
                
                // MARK: - Orbit Controls (Rotation Speed, Center Reset)
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
                
                // MARK: - Floating Executive Client Dossier Card (Ripplix / Wise Spring)
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
            if let client = clientForWhatsApp {
                WhatsAppSettlerModal(client: client)
            }
        }
    }
    
    // MARK: - Parametric Calculations
    private func calculateOrbitRadius(for client: Client, maxRadius: CGFloat) -> CGFloat {
        let outstanding = client.outstandingBalance
        if outstanding <= 500 {
            // Settled planets stay very close to GAUREX nucleus
            return maxRadius * 0.38
        } else if outstanding <= 25000 {
            // Moderate receivables in mid orbital ring
            let ratio = CGFloat(outstanding / 25000.0)
            return (maxRadius * 0.38) + (maxRadius * 0.30 * ratio)
        } else {
            // High outstanding planets gravitate outward
            let ratio = min(1.0, CGFloat((outstanding - 25000.0) / 75000.0))
            return (maxRadius * 0.68) + (maxRadius * 0.30 * ratio)
        }
    }
    
    private func calculatePlanetSize(for client: Client) -> CGFloat {
        let total = client.totalInvoiced
        if total <= 10000 {
            return 28.0
        } else if total <= 50000 {
            return 36.0
        } else if total <= 150000 {
            return 44.0
        } else {
            return 52.0 // Enterprise Gas Giant
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
        case .lead:
            return LinearGradient(
                colors: [Color.gaurexDeepPlum, Color(red: 0.95, green: 0.55, blue: 0.20)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .inactive:
            return LinearGradient(
                colors: [Color.gray, Color.slateNavy],
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
                
                // Initials
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
            
            // Action Buttons
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
