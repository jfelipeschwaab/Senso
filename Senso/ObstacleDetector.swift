//
//  ObstacleDetector.swift
//  Senso
//

import Vision
import CoreVideo
import CoreGraphics

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
        return "\(subject) \(proximity.rawValue) \(position.rawValue)"
    }
}

final class ObstacleDetector {
    private let sequenceHandler = VNSequenceRequestHandler()

    func detect(in pixelBuffer: CVPixelBuffer,
                completion: @escaping ([DetectedObstacle]) -> Void) {
        let personRequest = VNDetectHumanRectanglesRequest()
        personRequest.upperBodyOnly = false

        let saliencyRequest = VNGenerateObjectnessBasedSaliencyImageRequest()

        do {
            try sequenceHandler.perform([personRequest, saliencyRequest], on: pixelBuffer)
        } catch {
            completion([])
            return
        }

        var obstacles: [DetectedObstacle] = []

        if let people = personRequest.results {
            for person in people where person.confidence > 0.5 {
                obstacles.append(makeObstacle(kind: .person, boundingBox: person.boundingBox))
            }
        }

        if let saliency = saliencyRequest.results?.first,
           let salientObjects = saliency.salientObjects {
            for object in salientObjects where object.confidence > 0.3 {
                let bbox = object.boundingBox
                let area = bbox.width * bbox.height
                guard area > 0.05 else { continue }
                obstacles.append(makeObstacle(kind: .object, boundingBox: bbox))
            }
        }

        completion(obstacles.sorted { $0.area > $1.area })
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
