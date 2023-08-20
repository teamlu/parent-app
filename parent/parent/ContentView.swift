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

            Button(action: {
                self.isRecording.toggle()
                if self.isRecording {
                    audioRecorder.beginRecording() // Updated method name
                } else {
                    audioRecorder.stopRecording()
                }
            }) {
                Image(systemName: isRecording ? "stop.fill" : "record.circle")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(isRecording ? .red : .gray)
            }

            // Other UI elements

            HStack(spacing: 20) {
                Button(action: {
                    // Placeholder for additional functionality
                }) {
                    Text("What can I do?")
                }
                .disabled(!audioRecorder.hasRecording)

                Button(action: {
                    audioRecorder.startOver() // Ensure this method exists in AudioRecorder
                    isRecording = false
                }) {
                    Text("Start again")
                }
                .disabled(!audioRecorder.hasRecording)
            }
        }
    }
}
