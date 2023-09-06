//
//  DadviceView.swift
//  parent
//
//  Created by Tim Lu on 8/19/23.
//

import Foundation
import Combine
import SwiftUI

class DadviceViewModel: ObservableObject {
    @Published var currentIndex: Int {
        didSet {
            refreshCurrentRecording()
            saveCurrentRecording()
        }
    }

    @Published var adviceText: String = "Loading advice..."
    @Published var currentRecording: Recording?
    
    var recordings: [URL]
    var recordingObjects: [Recording]
    var onRecordingUpdated: ((Recording) -> Void)?
    var audioRecorder: AudioRecorder?
    var audioFileManager = AudioFileManager()
    var audioFileUtility = AudioFileUtility()
    
    var atBeginning: Bool {
        return currentIndex == 0
    }
    
    var atEnd: Bool {
        return currentIndex == (recordings.count - 1)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(currentIndex: Int, recordings: [URL], recordingObjects: [Recording], audioRecorder: AudioRecorder? = nil) {
        self.currentIndex = currentIndex
        self.recordings = recordings
        self.recordingObjects = recordingObjects
        self.audioRecorder = audioRecorder  // Add this line
        
        if let initialRecording = getRecordingForCurrentIndex() {
            self.currentRecording = initialRecording
            self.adviceText = initialRecording.adviceText ?? "Loading advice..."
        }
        
        fetchDadAdvice()
    }
    
    func fetchDadAdvice() {
        // Simulated API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.adviceText = "Always remember to tie your shoes."
            if var current = self.currentRecording {
                current.adviceText = self.adviceText
                self.onRecordingUpdated?(current)
            }
        }
    }
    
    func moveToPrevious() {
        if !atBeginning {
            currentIndex -= 1
            refreshCurrentRecording()
            saveCurrentRecording()
        }
    }
    
    func moveToNext() {
        if !atEnd {
            currentIndex += 1
            refreshCurrentRecording()
            saveCurrentRecording()
        }
    }
    
    func saveCurrentRecording() {
        if let recording = getRecordingForCurrentIndex() {
            self.currentRecording = recording
        }
    }
    
    func refreshCurrentRecording() {
        if let newRecording = getRecordingForCurrentIndex() {
            currentRecording = newRecording
            adviceText = newRecording.adviceText ?? "Loading advice..."
        }
    }
    
    func getRecordingForCurrentIndex() -> Recording? {
        guard recordings.indices.contains(currentIndex) else {
            return nil
        }
        let currentURL = recordings[currentIndex]
        return recordingObjects.first { $0.url == currentURL }
    }
    
    func saveChanges(for recording: Recording) {
        // Save to UserDefaults
        audioFileManager.saveRecordingName(recording.name, for: recording.url)

        // Save to your recordingObjects array
        if let index = recordingObjects.firstIndex(where: { $0.url == recording.url }) {
            recordingObjects[index] = recording
        }
        
        // Notify AudioRecorder to update its list
        audioRecorder?.updateRecordingsList()
        
        // Call onRecordingUpdated to update the UI
        onRecordingUpdated?(recording)
    }
    
    func shareContent() {
        // Your sharing logic here
    }
}
