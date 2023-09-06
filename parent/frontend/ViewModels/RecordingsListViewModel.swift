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
    
    var audioFileUtility = AudioFileUtility()
    private var audioPlayer: AVAudioPlayer? = nil
    
    // Memoization dictionary to store DadviceViewModel instances
    private var dadviceViewModels: [UUID: DadviceViewModel] = [:]
    
    init(audioRecorder: AudioRecorder) {
        self.audioRecorder = audioRecorder
        // Load the initial list of recordings
        self.loadRecordings()
    }
    
    func loadRecordings() {
        self.recordings = audioRecorder.recordings.sorted { $0.date > $1.date }
        // Update duration for each recording
        for i in 0..<recordings.count {
            audioFileUtility.getDuration(for: recordings[i].url)
        }
    }

    func updateRecording(_ recording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index] = recording
            audioFileUtility.getDuration(for: recording.url)
        }
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

        // Stop playing the audio if it's currently playing
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }

        // Delete the file
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
                
                // Remove the recording from RecordingsListViewModel's list
                if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
                    recordings.remove(at: index)
                }

                // Remove the recording from AudioRecorder's list
                if let index = audioRecorder.recordings.firstIndex(where: { $0.id == recording.id }) {
                    audioRecorder.recordings.remove(at: index)
                }
                
                // Update the list in both places
                audioRecorder.updateRecordingsList()
                loadRecordings()

            } catch {
                print("Failed to delete recording: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at path: \(url.path)")
        }
    }

}
