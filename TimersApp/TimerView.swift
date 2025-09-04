import SwiftUI
import AVFoundation

struct TimerView: View {
    @EnvironmentObject var timerSettings: TimerSettings

    @State private var title: String
    let initialTime: Int
    @State private var timeRemaining: Int
    @State private var timerActive: Bool = false
    @State private var timerPaused: Bool = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var showTimesUp: Bool = false
    @State private var editingTitle: Bool = false
    @State private var newTitleText: String = ""
    
    init(title: String = "Timer", initialTime: Int) {
        _title = State(initialValue: title)
        self.initialTime = initialTime
        _timeRemaining = State(initialValue: initialTime)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Button(action: {
                newTitleText = title
                editingTitle = true
            }) {
                Text(title)
                    .font(.system(size: 72, weight: .bold, design: .default))
            }
            .buttonStyle(PlainButtonStyle())
            
            if showTimesUp {
                ZStack {
                    Text("Time's Up")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                        .scaleEffect(showTimesUp ? 1.2 : 0.8)
                        .opacity(showTimesUp ? 1 : 0)
                        .animation(.easeOut(duration: 0.5), value: showTimesUp)
                }
                Button("Repeat") {
                    repeatTimer()
                }
                .font(.title)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            } else {
                Text(timeString)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                if !timerActive && !isTimeZero {
                    Button("Start") {
                        guard !isTimeZero else { return }
                        showTimesUp = false
                        playStartSound()
                        startTimer()
                    }
                    .font(.title)
                    .padding()
                    .background(isTimeZero ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .disabled(isTimeZero)
                } else if timerPaused {
                    Button("Resume") {
                        showTimesUp = false
                        resumeTimer()
                    }
                    .font(.title)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                } else {
                    Button("Stop") {
                        pauseTimer()
                    }
                    .font(.title)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
        }
        .onDisappear {
            timerTask?.cancel()
        }
        .onAppear {
            if timerSettings.autoStart && !timerActive && !showTimesUp {
                timerSettings.autoStart = false
                showTimesUp = false
                playStartSound()
                startTimer()
            }
        }
        .sheet(isPresented: $editingTitle) {
            VStack(spacing: 16) {
                Text("Edit Title")
                    .font(.headline)
                TextField("Enter title", text: $newTitleText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                HStack(spacing: 32) {
                    Button("Cancel") {
                        editingTitle = false
                    }
                    .foregroundColor(.red)
                    Button("Save") {
                        title = newTitleText
                        editingTitle = false
                    }
                    .foregroundColor(.blue)
                }
                .padding(.top)
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
    
    private var timeString: String {
        let hours = timeRemaining / 3600
        let minutes = (timeRemaining % 3600) / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private var isTimeZero: Bool {
        timeRemaining == 0
    }
    
    private func startTimer() {
        timerActive = true
        timerPaused = false
        timerTask = Task {
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                await MainActor.run {
                    timeRemaining -= 1
                    if timeRemaining == 0 {
                        timerActive = false
                        timerPaused = false
                        playEndSound()
                        withAnimation {
                            showTimesUp = true
                        }
                    }
                }
            }
        }
    }
    
    private func pauseTimer() {
        timerPaused = true
        timerTask?.cancel()
        timerTask = nil
    }
    
    private func resumeTimer() {
        timerPaused = false
        timerTask = Task {
            while timeRemaining > 0 && !Task.isCancelled && !timerPaused {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled || timerPaused { break }
                await MainActor.run {
                    timeRemaining -= 1
                    if timeRemaining == 0 {
                        timerActive = false
                        timerPaused = false
                        playEndSound()
                        withAnimation {
                            showTimesUp = true
                        }
                    }
                }
            }
        }
    }
    
    // A satisfying pop sound will play when the timer starts. Ensure you have a sound file named `Pop.wav` in your Xcode project's main bundle.
    private func playStartSound() {
        guard let url = Bundle.main.url(forResource: "Pop", withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not play sound: \(error.localizedDescription)")
        }
    }
    
    private func playEndSound() {
        guard let url = Bundle.main.url(forResource: "TimesUp", withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not play end sound: \(error.localizedDescription)")
        }
    }
    
    private func repeatTimer() {
        timeRemaining = initialTime
        showTimesUp = false
        playStartSound()
        startTimer()
    }
}

#Preview {
    TimerView(title: "Custom Timer", initialTime: 5 * 60)
}
