//
//  JourneyView.swift
//  Senso
//

import SwiftUI

struct JourneyView: View {
    @ObservedObject var viewModel: SensoViewModel
    @ObservedObject var bluetooth: BluetoothMockManager
    var onEnd: () -> Void

    @State private var pulseConnected = false

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    pageHeader
                    environmentSection
                    hapticSection
                    actionsSection
                }
                .padding(20)
                .padding(.bottom, 100)
            }
        }
        .background(SensoColor.surfaceBright.ignoresSafeArea())
        .onAppear {
            pulseConnected = true
            if !viewModel.isRunning { viewModel.start() }
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            iconButton(name: "sensors")
            Spacer()
            Text("Senso")
                .font(SensoFont.headlineMd)
                .foregroundStyle(SensoColor.primary)
            Spacer()
            iconButton(name: "gearshape")
        }
        .padding(.horizontal, 20)
        .frame(height: 72)
        .background(SensoColor.surfaceBright)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(SensoColor.outlineVariant)
                .frame(height: 2)
        }
    }

    private func iconButton(name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(SensoColor.primary)
            .frame(width: 56, height: 56)
    }

    // MARK: - Page Header

    private var pageHeader: some View {
        HStack(alignment: .center) {
            Text("Trajeto em Curso")
                .font(SensoFont.headlineLgMobile)
                .foregroundStyle(SensoColor.onSurface)
            Spacer()
            HStack(spacing: 8) {
                Circle()
                    .fill(SensoColor.primary)
                    .frame(width: 12, height: 12)
                    .scaleEffect(pulseConnected ? 1.1 : 0.85)
                    .opacity(pulseConnected ? 1 : 0.6)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseConnected)
                Text("Conectado")
                    .font(SensoFont.labelMd)
                    .foregroundStyle(SensoColor.onSurfaceVariant)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(SensoColor.secondaryContainer, in: Capsule())
            .overlay(Capsule().stroke(SensoColor.outlineVariant, lineWidth: 2))
        }
    }

    // MARK: - Map

    private var mapSection: some View {
        ZStack(alignment: .bottom) {
            mapBackground
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(SensoColor.outlineVariant, lineWidth: 2)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Localização Atual")
                    .font(SensoFont.labelMd)
                    .foregroundStyle(SensoColor.onSurfaceVariant)
                Text("Avenida Paulista, 1578")
                    .font(SensoFont.headlineMd)
                    .foregroundStyle(SensoColor.onSurface)
                HStack(spacing: 6) {
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 14))
                    Text("Em movimento (4 km/h)")
                        .font(SensoFont.labelMd)
                }
                .foregroundStyle(SensoColor.primary)
                .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SensoColor.surfaceBright.opacity(0.95), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(SensoColor.outlineVariant, lineWidth: 2)
            )
            .padding(12)
        }
    }

    private var mapBackground: some View {
        ZStack {
            SensoColor.surfaceContainer
            // Stylized grid
            Canvas { ctx, size in
                let spacing: CGFloat = 32
                var x: CGFloat = 0
                while x < size.width {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    ctx.stroke(path, with: .color(SensoColor.outlineVariant.opacity(0.5)), lineWidth: 1)
                    x += spacing
                }
                var y: CGFloat = 0
                while y < size.height {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    ctx.stroke(path, with: .color(SensoColor.outlineVariant.opacity(0.5)), lineWidth: 1)
                    y += spacing
                }
                // Route path
                var route = Path()
                route.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.85))
                route.addCurve(
                    to: CGPoint(x: size.width * 0.7, y: size.height * 0.3),
                    control1: CGPoint(x: size.width * 0.4, y: size.height * 0.7),
                    control2: CGPoint(x: size.width * 0.4, y: size.height * 0.4)
                )
                route.addLine(to: CGPoint(x: size.width * 0.9, y: size.height * 0.15))
                ctx.stroke(route, with: .color(SensoColor.primary), lineWidth: 5)
            }
            // Pin
            VStack(spacing: 0) {
                Image(systemName: "location.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(SensoColor.primary, in: Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 3))
                    .shadow(radius: 4)
            }
            .offset(x: -40, y: -10)
        }
    }

    // MARK: - Environment / Camera Feed

    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Visão do Ambiente")
                    .font(SensoFont.labelXl)
                    .foregroundStyle(SensoColor.onSurfaceVariant)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 12))
                    Text("Ao Vivo")
                        .font(SensoFont.labelMd)
                }
                .foregroundStyle(SensoColor.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(SensoColor.primaryFixed, in: Capsule())
                .overlay(Capsule().stroke(SensoColor.primaryFixedDim, lineWidth: 2))
            }

            ZStack {
                CameraPreview(session: viewModel.camera.session)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(SensoColor.outlineVariant, lineWidth: 2)
                    )

                RoundedRectangle(cornerRadius: 10)
                    .stroke(SensoColor.primary.opacity(0.25), lineWidth: 4)
                    .padding(16)
                    .frame(height: 220)
                    .allowsHitTesting(false)

                VStack {
                    HStack {
                        Text(viewModel.statusMessage)
                            .font(SensoFont.labelMd)
                            .foregroundStyle(SensoColor.onSurface)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(SensoColor.surfaceBright.opacity(0.92), in: RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(SensoColor.outlineVariant, lineWidth: 2)
                            )
                        Spacer()
                    }
                    Spacer()
                }
                .padding(20)
                .frame(height: 220)
            }
        }
    }

    // MARK: - Haptic

    private enum HapticSide { case left, stop, right }

    private var activeHaptic: HapticSide {
        guard let obstacle = viewModel.lastObstacles.first else { return .stop }
        if obstacle.proximity == .near { return .stop }
        switch obstacle.position {
        case .left: return .right   // obstacle on left → steer right
        case .right: return .left   // obstacle on right → steer left
        case .center: return .stop
        }
    }

    private var hapticSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status de Vibração")
                .font(SensoFont.labelXl)
                .foregroundStyle(SensoColor.onSurfaceVariant)

            HStack(spacing: 8) {
                hapticCard(title: "Esquerda", icon: "iphone.radiowaves.left.and.right", active: activeHaptic == .left)
                hapticCard(title: "Parar", icon: "hand.raised.fill", active: activeHaptic == .stop, isStop: true)
                hapticCard(title: "Direita", icon: "iphone.radiowaves.left.and.right", active: activeHaptic == .right)
            }

            Text(hapticDescription)
                .font(SensoFont.bodyMd)
                .foregroundStyle(SensoColor.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
    }

    private var hapticDescription: String {
        switch activeHaptic {
        case .left: return "Obstáculo à direita. Direcionando usuário para a esquerda."
        case .right: return "Obstáculo à esquerda. Direcionando usuário para a direita."
        case .stop:
            if let o = viewModel.lastObstacles.first, o.proximity == .near {
                return "Obstáculo muito próximo. Solicitando parada."
            }
            return "Caminho livre. Siga em frente."
        }
    }

    private func hapticCard(title: String, icon: String, active: Bool, isStop: Bool = false) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: active ? 44 : 36, weight: .bold))
                .foregroundStyle(active ? SensoColor.onPrimaryContainer : SensoColor.onSurfaceVariant)
                .scaleEffect(active ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: active)
            Text(title)
                .font(SensoFont.labelXl)
                .foregroundStyle(active ? SensoColor.onPrimaryContainer : SensoColor.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .background(active ? SensoColor.primaryContainer : SensoColor.surfaceContainerLow,
                    in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(active ? SensoColor.primary : SensoColor.outlineVariant,
                        lineWidth: active ? 4 : 2)
        )
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 16) {
            Button {
                // Mock call
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                    Text("Ligar para Usuário")
                }
                .font(SensoFont.labelXl)
                .foregroundStyle(SensoColor.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(SensoColor.surfaceBright, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(SensoColor.primary, lineWidth: 2)
                )
            }

            Button {
                viewModel.stop()
                bluetooth.disconnect()
                onEnd()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                    Text("Encerrar Trajeto")
                }
                .font(SensoFont.labelXl)
                .foregroundStyle(SensoColor.onError)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(SensoColor.error, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.top, 8)
    }
}
