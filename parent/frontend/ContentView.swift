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
    @State private var navigateToRecordingsListView = false

    var body: some View {
        NavigationView { // Add this NavigationView
            VStack {
                Text(audioRecorder.stopwatchText)
                    .font(.largeTitle)

                Button(action: {
                    self.isRecording.toggle()
                    if self.isRecording {
                        audioRecorder.beginRecording()
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
                    NavigationLink("", destination: RecordingsListView(audioRecorder: audioRecorder), isActive: $navigateToRecordingsListView)

                    Button("What can I do?") {
                        audioRecorder.finalizeRecording() // Finalize the recording
                        navigateToRecordingsListView = true // Trigger the navigation
                    }
                    .disabled(!(audioRecorder.hasRecording && audioRecorder.isPaused))
                    
                    Button(action: {
                        audioRecorder.startOver()
                        isRecording = false
                    }) {
                        Text("Start again")
                    }
                    .disabled(!audioRecorder.hasRecording)
                }
            }
        } // Close NavigationView
    }
}
