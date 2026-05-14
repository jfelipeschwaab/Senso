//
//  SpeechAnnouncer.swift
//  Senso
//

import AVFoundation

final class SpeechAnnouncer: @unchecked Sendable {
    private let synthesizer = AVSpeechSynthesizer()
    private let lock = NSLock()
    private var lastAnnouncement: String = ""
    private var lastAnnouncementDate = Date.distantPast
    private let repeatCooldown: TimeInterval = 1.5

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

        lock.lock()
        let sameAsLast = text == lastAnnouncement
        let withinCooldown = now.timeIntervalSince(lastAnnouncementDate) < repeatCooldown
        if sameAsLast && withinCooldown {
            lock.unlock()
            return
        }
        lastAnnouncement = text
        lastAnnouncementDate = now
        lock.unlock()

        // New text takes over immediately; finish current word for clean audio.
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 1.05
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }
}
