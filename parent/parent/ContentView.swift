//
//  ContentView.swift
//  parent
//
//  Created by Tim Lu on 8/19/23.
//
import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var milliseconds: Int = 0
    @State private var timer: Timer? = nil
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack {
            if audioRecorder.recordingFinished {
                ProcessOrDeleteControls(audioRecorder: audioRecorder, milliseconds: $milliseconds, timer: $timer)

                PlaybackControls(audioRecorder: audioRecorder, audioPlayer: $audioPlayer)
            }

            Text("\(String(format: "%02d", milliseconds / 60000)):\(String(format: "%02d", (milliseconds / 1000) % 60)):\(String(format: "%02d", (milliseconds / 100) % 10))")
                .font(.title)

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)

            Text("Kinmo")

            HStack {
                Button(action: {
                    audioRecorder.startRecording()
                    startStopwatch()
                }) {
                    Text("Start Recording")
                }
                .disabled(audioRecorder.recording && !audioRecorder.recordingPaused)

                Button(action: {
                    audioRecorder.pauseRecording()
                    pauseStopwatch()
                }) {
                    Text("Pause Recording")
                }
                .disabled(!audioRecorder.recording || audioRecorder.recordingPaused)

                Button(action: {
                    audioRecorder.stopRecording()
                    stopStopwatch()
                }) {
                    Text("Finish Recording")
                }
                .disabled(!audioRecorder.recording && !audioRecorder.recordingPaused)
            }
            .padding()
        }
    }

    func startStopwatch() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            milliseconds += 1
        }
    }

    func pauseStopwatch() {
        timer?.invalidate()
    }

    func stopStopwatch() {
        timer?.invalidate()
        timer = nil
    }
}

struct ProcessOrDeleteControls: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Binding var milliseconds: Int
    @Binding var timer: Timer?

    var body: some View {
        HStack {
            Button("Process the audio") {
                // Processing code here
            }

            Button("Delete the audio") {
                audioRecorder.resetRecording()
                milliseconds = 0
                timer?.invalidate()
                timer = nil
            }
        }
    }
}

struct PlaybackControls: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Binding var audioPlayer: AVAudioPlayer?

    var body: some View {
        HStack {
            Button(action: {
                playAudio(rewind: true)
            }) {
                Image(systemName: "backward.end.fill")
            }

            Button(action: {
                playAudio()
            }) {
                Image(systemName: "play.fill")
            }

            Button(action: {
                playAudio(forward: true)
            }) {
                Image(systemName: "forward.end.fill")
            }
        }
    }

    private func playAudio(rewind: Bool = false, forward: Bool = false) {
        guard let data = audioRecorder.recordedData else { return }

        do {
            audioPlayer = try AVAudioPlayer(data: data)
            if rewind { audioPlayer?.currentTime -= 15 }
            if forward { audioPlayer?.currentTime += 15 }
            audioPlayer?.play()
        } catch {
            print("Audio playback failed.")
        }
    }
}
