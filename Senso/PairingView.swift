//
//  PairingView.swift
//  Senso
//

import SwiftUI

struct PairingView: View {
    @ObservedObject var bluetooth: BluetoothMockManager
    var onConnected: () -> Void

    @State private var pulse = false

    var body: some View {
        ZStack {
            SensoColor.surfaceBright.ignoresSafeArea()

            VStack(spacing: 32) {
                header

                Spacer(minLength: 0)

                bluetoothVisual

                statusBlock

                Spacer(minLength: 0)

                actionButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .onAppear {
            pulse = true
            if case .idle = bluetooth.state {
                bluetooth.startScan()
            }
        }
        .onChange(of: stateKey) { _ in
            if case .connected = bluetooth.state {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    onConnected()
                }
            }
        }
    }

    private var stateKey: String {
        switch bluetooth.state {
        case .idle: return "idle"
        case .scanning: return "scanning"
        case .found: return "found"
        case .pairing(let p): return "pairing-\(Int(p * 100))"
        case .connected: return "connected"
        case .failed: return "failed"
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "sensors")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(SensoColor.primary)
                .frame(width: 56, height: 56)

            Spacer()

            Text("Senso")
                .font(SensoFont.headlineMd)
                .foregroundStyle(SensoColor.primary)

            Spacer()

            Image(systemName: "gearshape")
                .font(.system(size: 24))
                .foregroundStyle(SensoColor.primary)
                .frame(width: 56, height: 56)
        }
    }

    private var bluetoothVisual: some View {
        ZStack {
            pulseRing(size: 120, delay: 0.0)
            pulseRing(size: 180, delay: 0.2)
            pulseRing(size: 240, delay: 0.4)

            Circle()
                .fill(isConnected ? SensoColor.primary : SensoColor.primaryContainer)
                .frame(width: 110, height: 110)
                .shadow(color: SensoColor.primary.opacity(0.25), radius: 16, y: 6)

            Image(systemName: iconName)
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(height: 280)
    }

    private func pulseRing(size: CGFloat, delay: Double) -> some View {
        Circle()
            .stroke(SensoColor.primaryFixedDim, lineWidth: 2)
            .frame(width: size, height: size)
            .scaleEffect(pulse ? 1.05 : 0.95)
            .opacity(pulse ? 0.3 : 0.8)
            .animation(
                .easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(delay),
                value: pulse
            )
    }

    private var iconName: String {
        switch bluetooth.state {
        case .idle, .scanning: return "dot.radiowaves.left.and.right"
        case .found: return "eyeglasses"
        case .pairing: return "arrow.triangle.2.circlepath"
        case .connected: return "checkmark"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }

    private var isConnected: Bool {
        if case .connected = bluetooth.state { return true }
        return false
    }

    private var statusBlock: some View {
        VStack(spacing: 12) {
            Text(titleText)
                .font(SensoFont.headlineLgMobile)
                .foregroundStyle(SensoColor.onSurface)
                .multilineTextAlignment(.center)

            Text(subtitleText)
                .font(SensoFont.bodyMd)
                .foregroundStyle(SensoColor.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            if case .pairing(let progress) = bluetooth.state {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(SensoColor.primary)
                    .frame(maxWidth: 260)
                    .padding(.top, 8)
            }

            if case .found = bluetooth.state {
                deviceCard
            }
            if case .connected = bluetooth.state {
                deviceCard
            }
        }
    }

    private var deviceCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "eyeglasses")
                .font(.system(size: 24))
                .foregroundStyle(SensoColor.primary)
                .frame(width: 48, height: 48)
                .background(SensoColor.primaryFixed, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(bluetooth.deviceName)
                    .font(SensoFont.labelXl)
                    .foregroundStyle(SensoColor.onSurface)
                Text("Sinal \(bluetooth.rssi) dBm")
                    .font(SensoFont.labelMd)
                    .foregroundStyle(SensoColor.onSurfaceVariant)
            }
            Spacer()

            if isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(SensoColor.primary)
            }
        }
        .padding(16)
        .background(SensoColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(SensoColor.outlineVariant, lineWidth: 2)
        )
        .padding(.top, 8)
    }

    private var titleText: String {
        switch bluetooth.state {
        case .idle, .scanning: return "Procurando óculos…"
        case .found: return "Dispositivo encontrado"
        case .pairing: return "Pareando…"
        case .connected: return "Conectado!"
        case .failed: return "Falha na conexão"
        }
    }

    private var subtitleText: String {
        switch bluetooth.state {
        case .idle, .scanning:
            return "Mantenha os óculos Senso próximos ao celular."
        case .found:
            return "Toque em conectar para parear com seus óculos."
        case .pairing:
            return "Estabelecendo conexão segura com o dispositivo."
        case .connected:
            return "Tudo pronto. Vamos iniciar seu trajeto."
        case .failed(let reason):
            return reason
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        switch bluetooth.state {
        case .found:
            primaryButton(title: "Conectar", icon: "link") {
                bluetooth.pair()
            }
        case .idle, .scanning, .pairing:
            EmptyView()
        case .connected:
            primaryButton(title: "Continuar", icon: "arrow.right") {
                onConnected()
            }
        case .failed:
            primaryButton(title: "Tentar novamente", icon: "arrow.clockwise") {
                bluetooth.startScan()
            }
        }
    }

    private func primaryButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(SensoFont.labelXl)
            .foregroundStyle(SensoColor.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(SensoColor.primary, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}
