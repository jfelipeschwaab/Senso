//
//  SpeechAnnouncer.swift
//  Senso
//

import AVFoundation

final class SpeechAnnouncer: @unchecked Sendable {
    private let synthesizer = AVSpeechSynthesizer()
    private let lock = NSLock()
    private var lastAnnouncement: String = ""

    init() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback,
                                                        mode: .spokenAudio,
                                                        options: [.duckOthers, .mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        #endif
    }

    /// Speaks `text` once. Repeated calls with the same text are ignored until
    /// either a different text is announced or `reset()` is called.
    func announce(_ text: String) {
        lock.lock()
        if text == lastAnnouncement {
            lock.unlock()
            return
        }
        lastAnnouncement = text
        lock.unlock()

        // New, distinct message — interrupt current speech at end of current word.
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 1.05
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }

    /// Clears the last announcement memory so the next call to `announce` will
    /// speak even if the text matches a previously spoken one. Use when the
    /// situation changes meaningfully (e.g., path becomes clear).
    func reset() {
        lock.lock()
        lastAnnouncement = ""
        lock.unlock()
    }
}
