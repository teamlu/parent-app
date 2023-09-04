//
//  AudioRecorder.swift
//  parent
//
//  Created by Tim Lu on 8/19/23.
//
// NOTE: CONSOLIDATING FILE MANAGEMENT METHODS
//       Consider moving the file management functions (prepareRecorder, deleteRecording,
//       getDocumentsDirectory, fetchRecordings) to a separate helper class to keep your
//       AudioRecorder class focused on audio recording logic. This is more of an architectural
//       choice and depends on how complex your project is.

import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    
    // MARK: - Properties
    @Published var stopwatchText: String = "00:00:00"  // Stopwatch time in "HH:MM:SS" format
    @Published var hasRecording: Bool = false            // Indicates if a recording is available
    @Published var isPaused: Bool = false                // Indicates if recording is paused
    @Published var recordings: [URL] = []                // List of saved recording URLs
    
    private var audioRecorder: AVAudioRecorder!          // Audio recording functionality
    private var isNewRecording: Bool = true              // New session or continuation of paused one
    private var stopwatchTimer: Timer?                   // Stopwatch timer object
    private var stopwatchStartDate: Date?                // Start date for stopwatch elapsed time
    private var stopwatchElapsedTime: TimeInterval = 0   // Total elapsed time for stopwatch

    // MARK: - Initialization
    override init() {
        super.init()
        prepareRecordingSession()
    }
    
    private func prepareRecordingSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
    }
    
    private func preparePlaybackSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            print("Failed to set up playback session")
        }
    }
    
    // MARK: - Recording Controls
    func beginRecording() {
        prepareRecordingSession()
        if isPaused {
            stopwatchStartDate = Date()
            audioRecorder.record()
            isPaused = false
        } else {
            if isNewRecording {
                let uniqueName = generateUniqueFileName()
                prepareRecorder(uniqueName: uniqueName)
            }
            audioRecorder.record()
            stopwatchStartDate = Date()
            stopwatchElapsedTime = 0
        }
        startStopwatch()
        hasRecording = true
    }
    
    func stopRecording() {
        audioRecorder.pause()
        stopwatchElapsedTime += Date().timeIntervalSince(stopwatchStartDate!)
        stopwatchStartDate = nil
        isPaused = true
        isNewRecording = false // Set to false when paused
        stopStopwatch()
    }
    
    func finalizeRecording() {
        audioRecorder.stop()
        resetStopwatch()
        updateRecordingsList()  // Update the recordings list
        isNewRecording = true // Set to true when finalized
        isPaused = false
    }
    
    private func generateUniqueFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return "recording_\(dateFormatter.string(from: Date())).m4a"
    }

    // MARK: - File Management
    private func prepareRecorder(uniqueName: String) {
        do {
            let url = getDocumentsDirectory().appendingPathComponent(uniqueName)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print("Failed to set up audio recorder: \(error)")
        }
    }

    func deleteRecording(url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
                if let index = recordings.firstIndex(of: url) {
                    recordings.remove(at: index)
                }
                updateRecordingsList()  // Update the recordings list
            } catch {
                print("Failed to delete recording: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at path: \(url.path)")
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func updateRecordingsList() {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: [])
            recordings = directoryContents.filter { $0.pathExtension == "m4a" }
        } catch {
            print("Could not fetch recordings: \(error)")
        }
    }

    // MARK: - Stopwatch Controls
    private func startStopwatch() {
        stopwatchTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.updateStopwatch()
        }
    }

    private func stopStopwatch() {
        stopwatchTimer?.invalidate()
    }

    private func resetStopwatch() {
        stopwatchTimer?.invalidate()
        stopwatchText = "00:00:00"
        stopwatchElapsedTime = 0
        stopwatchStartDate = nil
    }

    private func updateStopwatch() {
        let elapsedTime = stopwatchStartDate != nil ? Date().timeIntervalSince(stopwatchStartDate!) : 0
        let totalElapsedTime = stopwatchElapsedTime + elapsedTime
        let minutes = Int(totalElapsedTime / 60)
        let seconds = Int(totalElapsedTime) % 60
        let milliseconds = Int((totalElapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        stopwatchText = String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
}
