//
//  ContentView.swift
//  TimerApp
//
//  Created by Yonatan Golestany on 23/07/2025.
//

import SwiftUI
import RealityKit
import RealityKitContent

let loopingCount = 50
let secondsRange = Array(0..<60)
let loopingSeconds = Array(repeating: secondsRange, count: loopingCount).flatMap { $0 }
let loopingMinutes = loopingSeconds
let hoursRange = Array(0..<24)
let loopingHours = Array(repeating: hoursRange, count: loopingCount).flatMap { $0 }
let middleIndex = loopingSeconds.count / 2

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject var timerSettings: TimerSettings

    @State private var selectedHoursIndex: Int = loopingHours.count / 2
    @State private var selectedSecondsIndex: Int = loopingSeconds.count / 2
    @State private var selectedMinutesIndex: Int = loopingMinutes.count / 2
    
    var selectedHours: Int { loopingHours[selectedHoursIndex] }
    var selectedSeconds: Int { loopingSeconds[selectedSecondsIndex] }
    var selectedMinutes: Int { loopingMinutes[selectedMinutesIndex] }

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer(minLength: 30)
                Text("Countdown")
                    .font(.system(size: 38, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                // Pickers Row
                HStack(alignment: .center, spacing: 12) {
                    VStack(spacing: 4) {
                        Text("Sec")
                            .font(.system(.headline, design: .monospaced)).bold()
                            .foregroundColor(.white)
                        Picker("", selection: $selectedSecondsIndex) {
                            ForEach(0..<loopingSeconds.count, id: \.self) { i in
                                Text("\(loopingSeconds[i])")
                                    .font(.system(.body, design: .monospaced))
                                    .tag(i)
                            }
                        }
                        .frame(width: 70, height: 120)
                        .clipped()
                        .pickerStyle(.wheel)
                        .background(Color(.systemGray5).opacity(0.28))
                        .cornerRadius(12)
                        .onAppear {
                            selectedSecondsIndex = middleIndex
                        }
                    }
                    VStack(spacing: 4) {
                        Text("Min")
                            .font(.system(.headline, design: .monospaced)).bold()
                            .foregroundColor(.white)
                        Picker("", selection: $selectedMinutesIndex) {
                            ForEach(0..<loopingMinutes.count, id: \.self) { i in
                                Text("\(loopingMinutes[i])")
                                    .font(.system(.body, design: .monospaced))
                                    .tag(i)
                            }
                        }
                        .frame(width: 70, height: 120)
                        .clipped()
                        .pickerStyle(.wheel)
                        .background(Color(.systemGray5).opacity(0.28))
                        .cornerRadius(12)
                        .onAppear {
                            selectedMinutesIndex = middleIndex
                        }
                    }
                    VStack(spacing: 4) {
                        Text("Hour")
                            .font(.system(.headline, design: .monospaced)).bold()
                            .foregroundColor(.white)
                        Picker("", selection: $selectedHoursIndex) {
                            ForEach(0..<loopingHours.count, id: \.self) { i in
                                Text("\(loopingHours[i])")
                                    .font(.system(.body, design: .monospaced))
                                    .tag(i)
                            }
                        }
                        .frame(width: 70, height: 120)
                        .clipped()
                        .pickerStyle(.wheel)
                        .background(Color(.systemGray5).opacity(0.28))
                        .cornerRadius(12)
                        .onAppear {
                            selectedHoursIndex = loopingHours.count / 2
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // Buttons Row
                HStack {
                    Button(action: {
                        // Start timer (open timerWindow, pass values if needed)
                        print("Starting timer with: \(selectedHours)h \(selectedMinutes)m \(selectedSeconds)s")
                        let totalSeconds = (selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds
                        if totalSeconds > 0 {
                            timerSettings.initialTime = totalSeconds
                        }
                        timerSettings.autoStart = true
                        openWindow(id: "timerWindow")
                    }) {
                        Text("Start")
                            .font(.system(size: 22, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 70)
                    }
                    .background(Color.green)
                    .cornerRadius(22)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .preferredColorScheme(.dark)
        .environmentObject(TimerSettings())
}
