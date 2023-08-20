//
//  AudioRecorder.swift
//  parent
//
//  Created by Tim Lu on 8/19/23.
//
import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    @Published var stopwatchText: String = "00:00:00"
    @Published var isPlaying: Bool = false
    @Published var hasRecording: Bool = false
    
    private var stopwatchTimer: Timer?
    private var recordingStartTime: Date?
    
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
    
    func startRecording() {
        audioRecorder.record()
        recordingStartTime = Date()
        startStopwatch()
        hasRecording = false
    }

    func stopRecording() {
        audioRecorder.stop()
        stopStopwatch()
        hasRecording = true
    }
    
    func pauseRecording() {
        audioRecorder.pause()
        stopStopwatch() // Use the same function for stopping the stopwatch
    }

    func deleteRecording() {
        stopRecording()
        resetStopwatch()
        do {
            try FileManager.default.removeItem(at: getDocumentsDirectory().appendingPathComponent("recording.m4a"))
        } catch {
            print("Failed to delete recording")
        }
        hasRecording = false
        audioPlayer = nil
    }
    
    func rewind15Seconds() {
        let newPosition = max(audioPlayer.currentTime - 15, 0)
        audioPlayer.currentTime = newPosition
    }

    func forward15Seconds() {
        let newPosition = min(audioPlayer.currentTime + 15, audioPlayer.duration)
        audioPlayer.currentTime = newPosition
    }

    func togglePlayback() {
        if audioPlayer == nil {
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: getDocumentsDirectory().appendingPathComponent("recording.m4a"))
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
            } catch {
                print("Playback failed")
            }
        }

        if isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }

        isPlaying.toggle()
    }
    
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
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func startStopwatch() {
        stopwatchTimer?.invalidate()
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
        let elapsedTime = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        stopwatchText = String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
