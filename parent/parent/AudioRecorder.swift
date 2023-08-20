//
//  AudioRecorder.swift
//  parent
//
//  Created by Tim Lu on 8/19/23.
//
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    @Published var recording = false
    @Published var recordingPaused = false
    @Published var recordingFinished = false
    @Published var recordedData: Data?

    private var audioRecorder: AVAudioRecorder!

    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)

            if recordingPaused {
                audioRecorder.record()
                recordingPaused = false
            } else {
                let url = getDocumentsDirectory().appendingPathComponent("recording.m4a")
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]

                audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
            }

            recording = true
            recordingFinished = false
        } catch {
            print("Could not start recording")
        }
    }

    func pauseRecording() {
        if audioRecorder.isRecording {
            audioRecorder.pause()
            recordingPaused = true
        }
    }

    func stopRecording() {
        if audioRecorder.isRecording || recordingPaused {
            audioRecorder.stop()
            if let data = try? Data(contentsOf: audioRecorder.url) {
                recordedData = data
            }
            recording = false
            recordingPaused = false
            recordingFinished = true
        }
    }

    func resetRecording() {
        stopRecording()
        recordingFinished = false
        recordedData = nil
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording()
        }
    }
}
