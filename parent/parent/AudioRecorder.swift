//
//  AudioRecorder.swift
//  parent
//
//  Created by Tim Lu on 8/19/23.
//
import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {

    // MARK: - Properties
    @Published var stopwatchText: String = "00:00:00"
    @Published var hasRecording: Bool = false
    @Published var isPaused: Bool = false

    private var audioRecorder: AVAudioRecorder!
    private var stopwatchTimer: Timer?
    private var recordingStartTime: Date?
    private var totalElapsedTime: TimeInterval = 0

    // MARK: - Initialization
    override init() {
        super.init()
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        prepareRecorder()
    }

    // MARK: - Recording Controls
    func startRecording() {
        if isPaused {
            // Resume recording
            recordingStartTime = Date(timeIntervalSinceNow: -totalElapsedTime)
            audioRecorder.record()
            isPaused = false
        } else {
            // Start a new recording
            recordingStartTime = Date()
            totalElapsedTime = 0
            prepareRecorder()
            audioRecorder.record()
        }
        startStopwatch()
        hasRecording = true
    }

    func stopRecording() {
        audioRecorder.pause()
        totalElapsedTime += Date().timeIntervalSince(recordingStartTime!)
        isPaused = true
        stopStopwatch()
    }

    func startOver() {
        audioRecorder.stop()
        resetStopwatch()
        deleteRecording() // Delete the recording file
        hasRecording = false
        isPaused = false
        totalElapsedTime = 0
        prepareRecorder()
    }

    // MARK: - File Management
    private func prepareRecorder() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let url = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print("Failed to set up recorder")
        }
    }

    private func deleteRecording() {
        let url = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
                hasRecording = false
            } catch {
                print("Failed to delete previous recording")
            }
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
    }

    private func updateStopwatch() {
        guard let startTime = recordingStartTime else { return }
        var elapsedTime = Date().timeIntervalSince(startTime) + totalElapsedTime
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        stopwatchText = String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
}
