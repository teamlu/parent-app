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
    @Published var stopwatchText: String = "00:00:00"
    @Published var hasRecording: Bool = false
    @Published var isPaused: Bool = false
    @Published var recordings: [URL] = []
    
    private var audioRecorder: AVAudioRecorder!
    private var isNewRecording: Bool = true
    private var stopwatchTimer: Timer?
    private var stopwatchStartDate: Date?
    private var stopwatchElapsedTime: TimeInterval = 0
    
    private var audioFileManager = AudioFileManager()
    private var audioFileUtility = AudioFileUtility()
    
    // MARK: - Initialization
    override init() {
        super.init()
        prepareRecordingSession()
        updateRecordingsList()
    }
    
    private func prepareRecordingSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up recording session")
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
                let uniqueName = audioFileManager.generateUniqueFileName()
                audioRecorder = audioFileManager.prepareRecorder(uniqueName: uniqueName)
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
        isNewRecording = false
        stopStopwatch()
    }
    
    func finalizeRecording() {
        audioRecorder.stop()
        resetStopwatch()
        updateRecordingsList()
        isNewRecording = true
        isPaused = false
    }
    
    func updateRecordingsList() {
        recordings = audioFileManager.fetchRecordings()
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
    
    // MARK: - Wrapper Methods for Utility Functions
    
    func getDurationWrapper(for url: URL) -> String {
        return audioFileUtility.getDuration(for: url)
    }

    func getDateWrapper(for url: URL) -> String {
        return audioFileUtility.getDate(for: url)
    }

    func getStatusWrapper(for url: URL) -> AudioFileUtility.RecordingStatus {
        return audioFileUtility.getStatus(for: url)
    }
    
}
