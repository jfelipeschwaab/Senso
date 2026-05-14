//
//  SensoShortcuts.swift
//  Senso
//

import AppIntents

struct SensoShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .grayBlue

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartTrajectoryIntent(),
            phrases: [
                "Iniciar trajeto com \(.applicationName)",
                "Começar trajeto com \(.applicationName)",
                "Iniciar trajeto no \(.applicationName)",
                "\(.applicationName) iniciar trajeto",
                "\(.applicationName) começar trajeto"
            ],
            shortTitle: "Iniciar trajeto",
            systemImageName: "figure.walk.motion"
        )

        AppShortcut(
            intent: StopTrajectoryIntent(),
            phrases: [
                "Encerrar trajeto com \(.applicationName)",
                "Parar trajeto com \(.applicationName)",
                "\(.applicationName) parar trajeto"
            ],
            shortTitle: "Encerrar trajeto",
            systemImageName: "stop.circle"
        )
    }
}
