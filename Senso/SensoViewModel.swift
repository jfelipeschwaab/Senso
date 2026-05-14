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
    nonisolated private let detector = ObstacleDetector()
    nonisolated private let announcer = SpeechAnnouncer()

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
        detector.submit(pixelBuffer) { [weak self] obstacles in
            guard let self else { return }
            Task { @MainActor in
                self.handle(obstacles: obstacles)
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
