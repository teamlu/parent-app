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

    @State private var isRecording: Bool = false

    var body: some View {
        VStack {
            Text(audioRecorder.stopwatchText)
                .font(.largeTitle)

            RecordButtonView(isRecording: $isRecording, audioRecorder: audioRecorder)

            // Other UI elements can be placed here

            // Audio processing and deletion controls
            HStack(spacing: 20) {
                Button(action: {
                    // Placeholder for processing the audio logic here
                }) {
                    Text("What can I do?")
                }
                .disabled(!audioRecorder.hasRecording)

                Button(action: {
                    audioRecorder.deleteRecording()
                    isRecording = false
                }) {
                    Text("Start again")
                }
                .disabled(!audioRecorder.hasRecording)
            }

            // Playback controls (rewind, play/pause, forward)
            HStack {
                Button(action: {
                    audioRecorder.rewind15Seconds()
                }) {
                    Image(systemName: "backward.fill")
                }

                Button(action: {
                    audioRecorder.togglePlayback()
                }) {
                    Image(systemName: audioRecorder.isPlaying ? "pause.fill" : "play.fill") // Use system image or your custom image
                }

                Button(action: {
                    audioRecorder.forward15Seconds()
                }) {
                    Image(systemName: "forward.fill")
                }
            }
            .disabled(!audioRecorder.hasRecording || isRecording)
        }
    }

    struct RecordButtonView: UIViewRepresentable {
        @Binding var isRecording: Bool
        var audioRecorder: AudioRecorder

        func makeUIView(context: Context) -> RecordButton {
            let button = RecordButton()
            button.addTarget(context.coordinator, action: #selector(Coordinator.handleRecording(_:)), for: .touchUpInside)
            return button
        }

        func updateUIView(_ uiView: RecordButton, context: Context) {
            uiView.isRecording = isRecording
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self, audioRecorder: audioRecorder)
        }

        class Coordinator: NSObject {
            var parent: RecordButtonView
            var audioRecorder: AudioRecorder
            
            init(_ parent: RecordButtonView, audioRecorder: AudioRecorder) {
                self.parent = parent
                self.audioRecorder = audioRecorder
            }

            @objc func handleRecording(_ sender: RecordButton) {
                parent.isRecording.toggle()
                if parent.isRecording {
                    audioRecorder.startRecording()
                } else {
                    audioRecorder.stopRecording()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioRecorder: AudioRecorder())
    }
}
