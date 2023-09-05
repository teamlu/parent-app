// RecordingsListViewModel.swift
// parent
//
// Created by Tim Lu on 9/4/23.
//

import Foundation
import AVFoundation
import SwiftUI

class RecordingsListViewModel: ObservableObject {
    @Published var audioRecorder: AudioRecorder
    @Published var recordings: [Recording] = []
    
    private var audioPlayer: AVAudioPlayer? = nil
    
    // Memoization dictionary to store DadviceViewModel instances
    private var dadviceViewModels: [UUID: DadviceViewModel] = [:]
    
    init(audioRecorder: AudioRecorder) {
        self.audioRecorder = audioRecorder
        // Load the initial list of recordings
        self.loadRecordings()
    }
    
    func loadRecordings() {
        let loadedRecordings = audioRecorder.recordings.enumerated().map { (index, url) in
            let duration = getAudioDuration(url: url)
            return Recording(id: UUID(), name: "Recording \(index + 1)", date: Date(), duration: duration, status: .completed, url: url)
        }
        
        self.recordings = loadedRecordings.sorted { $0.date > $1.date }
    }
    
    func dadviceViewModel(for recording: Recording) -> DadviceViewModel {
        // Check for an existing ViewModel first
        if let existingViewModel = dadviceViewModels[recording.id] {
            return existingViewModel
        }
        
        let allRecordingURLs = recordings.map { $0.url }.reversed()
        let reversedRecordings = Array(recordings.reversed())
        let currentIndex = reversedRecordings.firstIndex(where: { $0.id == recording.id }) ?? 0
        
        // Create a new ViewModel if one doesn't exist
        let newViewModel = DadviceViewModel(
            currentIndex: currentIndex,
            recordings: Array(allRecordingURLs),
            recordingObjects: reversedRecordings
        )
        
        // Set the onRecordingUpdated closure
        newViewModel.onRecordingUpdated = { [weak self] updatedRecording in
            self?.updateRecording(updatedRecording)
        }
        
        newViewModel.refreshCurrentRecording()
        
        // Store the new ViewModel in the dictionary
        dadviceViewModels[recording.id] = newViewModel
        
        return newViewModel
    }
    
    func getAudioDuration(url: URL) -> Double {
        var duration: Double = 0
        do {
            let audioAsset = try AVAudioPlayer(contentsOf: url)
            duration = audioAsset.duration
        } catch {
            print("Could not load file for duration: \(error.localizedDescription)")
        }
        return duration
    }
    
    func updateRecording(_ recording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index] = recording
        }
    }
    
    func playRecording(recording: Recording) {
        let url = recording.url // Use the URL directly from the Recording object
        
        print("Attempting to play file at URL: \(url.path)")
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
                print("Playing \(url.path)") // Debugging
                
            } catch {
                print("Couldn't load the audio file: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at path: \(url.path)")
        }
    }
    
    func deleteRecording(recording: Recording) {
        let url = recording.url // Use the URL directly from the Recording object
        
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
                if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
                    recordings.remove(at: index)
                }
                
                // Remove the ViewModel associated with this recording
                dadviceViewModels.removeValue(forKey: recording.id)
                
            } catch {
                print("Failed to delete recording: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at path: \(url.path)")
        }
    }
}
