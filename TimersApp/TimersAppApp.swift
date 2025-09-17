//
//  TimerAppApp.swift
//  TimerApp
//
//  Created by Yonatan Golestany on 23/07/2025.
//

import SwiftUI

@main
struct TimerAppApp: App {
    let timerSettings = TimerSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerSettings)
                .environment(\.font, .system(size: 17, design: .monospaced))
        }
        WindowGroup(id: "timerWindow") {
            TimerView(initialTime: timerSettings.initialTime)
                .environmentObject(timerSettings)
                .environment(\.font, .system(size: 17, design: .monospaced))
        }
        .defaultSize(width: 550, height: 400)
    }
}
