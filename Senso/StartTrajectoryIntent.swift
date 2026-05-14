//
//  StartTrajectoryIntent.swift
//  Senso
//

import AppIntents

struct StartTrajectoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Iniciar trajeto"
    static var description = IntentDescription(
        "Abre o Senso e começa a identificar obstáculos à frente pela câmera."
    )

    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        SensoSession.viewModel.start()
        return .result()
    }
}

struct StopTrajectoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Encerrar trajeto"
    static var description = IntentDescription("Pausa a detecção de obstáculos do Senso.")

    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        SensoSession.viewModel.stop()
        return .result()
    }
}
