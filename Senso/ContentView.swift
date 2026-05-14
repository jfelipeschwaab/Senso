//
//  ContentView.swift
//  Senso
//
//  Created by João Felipe Schwaab on 14/05/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SensoViewModel()

    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.camera.session)
                .ignoresSafeArea()

            VStack {
                statusBanner
                Spacer()
                controls
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }

    private var statusBanner: some View {
        Text(viewModel.statusMessage)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 16))
            .accessibilityLiveRegion(.assertive)
    }

    private var controls: some View {
        Button(action: toggle) {
            Text(viewModel.isRunning ? "Pausar" : "Iniciar")
                .font(.title2.weight(.bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(viewModel.isRunning ? Color.yellow : Color.green,
                            in: RoundedRectangle(cornerRadius: 20))
        }
        .accessibilityHint("Ativa ou pausa a detecção de obstáculos pela câmera.")
    }

    private func toggle() {
        if viewModel.isRunning {
            viewModel.stop()
        } else {
            viewModel.start()
        }
    }
}

extension View {
    @ViewBuilder
    func accessibilityLiveRegion(_ priority: AccessibilityLiveRegionPriority) -> some View {
        if #available(iOS 17.0, *) {
            self.accessibilityAddTraits(.updatesFrequently)
        } else {
            self
        }
    }
}

enum AccessibilityLiveRegionPriority {
    case polite
    case assertive
}

#Preview {
    ContentView()
}
