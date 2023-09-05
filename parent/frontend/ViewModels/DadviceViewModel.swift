//
//  DadviceViewModel.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//

import Foundation
import Combine
import SwiftUI

class DadviceViewModel: ObservableObject {
    @Published var currentIndex: Int
    @Published var adviceText: String = "Loading advice..."
    @Published var currentRecording: Recording?

    var recordings: [URL]
    var recordingObjects: [Recording]
    var onRecordingUpdated: ((Recording) -> Void)?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(currentIndex: Int, recordings: [URL], recordingObjects: [Recording]) {
        self.currentIndex = currentIndex
        self.recordings = recordings
        self.recordingObjects = recordingObjects
        if let initialRecording = getRecordingForCurrentIndex() {
            self.currentRecording = initialRecording
        }
        fetchDadAdvice()
    }
    
    func fetchDadAdvice() {
        // Simulated API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.adviceText = "Always remember to tie your shoes."
        }
    }
    
    func moveToPrevious() {
        currentIndex = max(currentIndex - 1, 0)
        refreshCurrentRecording()
    }
    
    func moveToNext() {
        currentIndex = min(currentIndex + 1, recordings.count - 1)
        refreshCurrentRecording()
    }
    
    func refreshCurrentRecording() {
        if let newRecording = getRecordingForCurrentIndex() {
            currentRecording = newRecording
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
        // Save to persistent storage logic here
        if let index = recordingObjects.firstIndex(where: { $0.url == recording.url }) {
            recordingObjects[index] = recording
        }
        onRecordingUpdated?(recording)
    }
    
    func shareContent() {
        // Your sharing logic here
    }
}
