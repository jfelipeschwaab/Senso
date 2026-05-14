//
//  ContentView.swift
//  Senso
//
//  Created by João Felipe Schwaab on 14/05/26.
//

import SwiftUI

struct ContentView: View {
    enum Stage {
        case pairing
        case journey
    }

    @State private var stage: Stage = .pairing
    @StateObject private var bluetooth = BluetoothMockManager()
    @ObservedObject private var viewModel = SensoSession.viewModel

    var body: some View {
        Group {
            switch stage {
            case .pairing:
                PairingView(bluetooth: bluetooth) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        stage = .journey
                    }
                }
            case .journey:
                JourneyView(viewModel: viewModel, bluetooth: bluetooth) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        stage = .pairing
                    }
                    bluetooth.startScan()
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
