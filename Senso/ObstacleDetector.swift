//
//  ObstacleDetector.swift
//  Senso
//

import Vision
import CoreVideo
import CoreGraphics
import os

struct DetectedObstacle {
    enum Kind {
        case person
        case object
    }

    enum Position: String {
        case left = "à esquerda"
        case center = "à frente"
        case right = "à direita"
    }

    enum Proximity: String {
        case far = "longe"
        case medium = "perto"
        case near = "muito perto"
    }

    let kind: Kind
    let position: Position
    let proximity: Proximity
    let area: CGFloat

    var spokenDescription: String {
        let subject: String
        switch kind {
        case .person: subject = "Pessoa"
        case .object: subject = "Obstáculo"
        }
        if proximity == .near {
            return "\(subject) \(position.rawValue)!"
        }
        return "\(subject) \(proximity.rawValue) \(position.rawValue)"
    }
}

final class ObstacleDetector: @unchecked Sendable {
    private let inferenceQueue = DispatchQueue(label: "senso.detector.inference",
                                               qos: .userInitiated)
    private let sequenceHandler = VNSequenceRequestHandler()

    private let personRequest: VNDetectHumanRectanglesRequest = {
        let request = VNDetectHumanRectanglesRequest()
        request.upperBodyOnly = false
        return request
    }()

    private let saliencyRequest = VNGenerateObjectnessBasedSaliencyImageRequest()

    private let busyLock = OSAllocatedUnfairLock(initialState: false)
    private var frameCounter: UInt64 = 0
    private let saliencyEveryNFrames: UInt64 = 3

    /// Submits a frame for detection. Returns immediately. If a previous frame is
    /// still being processed, the new frame is dropped (back-pressure).
    /// `completion` is invoked on the inference queue — hop to main if needed.
    func submit(_ pixelBuffer: CVPixelBuffer,
                completion: @escaping ([DetectedObstacle]) -> Void) {
        let accepted = busyLock.withLock { busy -> Bool in
            guard !busy else { return false }
            busy = true
            return true
        }
        guard accepted else { return }

        inferenceQueue.async { [self] in
            let obstacles = runRequests(on: pixelBuffer)
            busyLock.withLock { $0 = false }
            completion(obstacles)
        }
    }

    private func runRequests(on pixelBuffer: CVPixelBuffer) -> [DetectedObstacle] {
        let runSaliency = (frameCounter % saliencyEveryNFrames == 0)
        frameCounter &+= 1

        let requests: [VNRequest] = runSaliency
            ? [personRequest, saliencyRequest]
            : [personRequest]

        do {
            try sequenceHandler.perform(requests, on: pixelBuffer)
        } catch {
            return []
        }

        var obstacles: [DetectedObstacle] = []

        if let people = personRequest.results {
            for person in people where person.confidence > 0.5 {
                obstacles.append(makeObstacle(kind: .person, boundingBox: person.boundingBox))
            }
        }

        if runSaliency,
           let saliency = saliencyRequest.results?.first,
           let salientObjects = saliency.salientObjects {
            for object in salientObjects where object.confidence > 0.3 {
                let bbox = object.boundingBox
                let area = bbox.width * bbox.height
                guard area > 0.05 else { continue }
                obstacles.append(makeObstacle(kind: .object, boundingBox: bbox))
            }
        }

        guard !obstacles.isEmpty else { return [] }
        let top = obstacles.max { $0.area < $1.area }!
        return [top]
    }

    private func makeObstacle(kind: DetectedObstacle.Kind,
                              boundingBox: CGRect) -> DetectedObstacle {
        let centerX = boundingBox.midX
        let position: DetectedObstacle.Position
        switch centerX {
        case ..<0.33: position = .left
        case 0.66...: position = .right
        default: position = .center
        }

        let area = boundingBox.width * boundingBox.height
        let proximity: DetectedObstacle.Proximity
        switch area {
        case ..<0.10: proximity = .far
        case ..<0.30: proximity = .medium
        default: proximity = .near
        }

        return DetectedObstacle(kind: kind,
                                position: position,
                                proximity: proximity,
                                area: area)
    }
}
