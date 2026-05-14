//
//  SpeechAnnouncer.swift
//  Senso
//

import AVFoundation

final class SpeechAnnouncer {
    private let synthesizer = AVSpeechSynthesizer()
    private var lastAnnouncement: String = ""
    private var lastAnnouncementDate = Date.distantPast
    private let minimumInterval: TimeInterval = 1.5

    init() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback,
                                                        mode: .spokenAudio,
                                                        options: [.duckOthers, .mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        #endif
    }

    func announce(_ text: String) {
        let now = Date()
        guard text != lastAnnouncement || now.timeIntervalSince(lastAnnouncementDate) > minimumInterval else {
            return
        }
        guard now.timeIntervalSince(lastAnnouncementDate) > minimumInterval else { return }

        lastAnnouncement = text
        lastAnnouncementDate = now

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }
}
