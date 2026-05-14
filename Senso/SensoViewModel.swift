//
//  SensoViewModel.swift
//  Senso
//

import Foundation
import Combine
import AVFoundation
import CoreVideo

@MainActor
final class SensoViewModel: ObservableObject {
    @Published private(set) var statusMessage: String = "Toque em iniciar para começar a detectar obstáculos."
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var lastObstacles: [DetectedObstacle] = []

    let camera = CameraManager()
    private let detector = ObstacleDetector()
    private let announcer = SpeechAnnouncer()

    private var isProcessingFrame = false
    private var lastDetectionTime = Date.distantPast
    private let detectionInterval: TimeInterval = 0.4

    init() {
        camera.delegate = self
    }

    func start() {
        camera.requestAccessAndStart()
        isRunning = true
        statusMessage = "Analisando o ambiente…"
        announcer.announce("Senso ativado")
    }

    func stop() {
        camera.stop()
        isRunning = false
        statusMessage = "Pausado."
    }
}

extension SensoViewModel: CameraManagerDelegate {
    nonisolated func cameraManager(_ manager: CameraManager, didOutput pixelBuffer: CVPixelBuffer) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard !self.isProcessingFrame else { return }
            let now = Date()
            guard now.timeIntervalSince(self.lastDetectionTime) >= self.detectionInterval else { return }
            self.lastDetectionTime = now
            self.isProcessingFrame = true

            self.detector.detect(in: pixelBuffer) { [weak self] obstacles in
                Task { @MainActor in
                    guard let self else { return }
                    self.handle(obstacles: obstacles)
                    self.isProcessingFrame = false
                }
            }
        }
    }

    private func handle(obstacles: [DetectedObstacle]) {
        lastObstacles = obstacles
        guard let priority = obstacles.first else {
            statusMessage = "Caminho livre."
            return
        }
        let message = priority.spokenDescription
        statusMessage = message
        if priority.proximity != .far {
            announcer.announce(message)
        }
    }
}
