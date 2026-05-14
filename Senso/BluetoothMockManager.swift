//
//  BluetoothMockManager.swift
//  Senso
//

import Foundation
import Combine

@MainActor
final class BluetoothMockManager: ObservableObject {
    enum State: Equatable {
        case idle
        case scanning
        case found(deviceName: String)
        case pairing(progress: Double)
        case connected(deviceName: String)
        case failed(reason: String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var rssi: Int = -78

    private var timerTask: Task<Void, Never>?

    func startScan() {
        timerTask?.cancel()
        state = .scanning
        timerTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard let self, !Task.isCancelled else { return }
            self.state = .found(deviceName: "Senso Glasses · SN-04A2")
        }
    }

    func pair() {
        guard case .found(let name) = state else { return }
        timerTask?.cancel()
        state = .pairing(progress: 0)

        timerTask = Task { [weak self] in
            for step in 1...20 {
                try? await Task.sleep(nanoseconds: 110_000_000)
                guard let self, !Task.isCancelled else { return }
                let progress = Double(step) / 20.0
                self.state = .pairing(progress: progress)
                self.rssi = -78 + Int.random(in: -3...5)
            }
            guard let self, !Task.isCancelled else { return }
            self.state = .connected(deviceName: name)
        }
    }

    func disconnect() {
        timerTask?.cancel()
        state = .idle
    }

    var deviceName: String {
        switch state {
        case .found(let name), .connected(let name): return name
        default: return "Senso Glasses"
        }
    }
}
