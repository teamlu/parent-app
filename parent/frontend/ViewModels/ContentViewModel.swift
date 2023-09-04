//
//  ContentViewModel.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//

import SwiftUI
import AVFoundation
import Combine

class ContentViewModel: ObservableObject {
    @Published var audioRecorder: AudioRecorder
    @Published var recordingState: RecordingState = .idle
    @Published var showSavedRecordings: Bool = false
    @Published var showSplash: Bool = true
    @Published var showParentAppText: Bool = false
    
    enum RecordingState {
        case idle
        case recording
        case paused
    }
    
    init(audioRecorder: AudioRecorder) {
        self.audioRecorder = audioRecorder
    }
    
    // Function to toggle recording state
    func toggleRecording() {
        switch recordingState {
        case .idle, .paused:
            recordingState = .recording
            audioRecorder.beginRecording()
        case .recording:
            recordingState = .paused
            audioRecorder.stopRecording()
        }
    }
    
    // Function to save the recording
    func saveRecording() {
        if recordingState == .paused {
            showSavedRecordings = true
            audioRecorder.finalizeRecording()
            audioRecorder.updateRecordingsList()
            recordingState = .idle
        }
    }
    
    // Function to handle splash screen visibility
    func handleSplashScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showSplash = false
                self.showParentAppText = true
            }
        }
    }
}
