//
//  RecordingsListViewModel.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//
import Foundation
import AVFoundation

class RecordingsListViewModel: ObservableObject {
    @Published var audioRecorder: AudioRecorder
    @Published var audioPlayer: AVAudioPlayer? = nil
    
    init(audioRecorder: AudioRecorder) {
        self.audioRecorder = audioRecorder
    }
    
    func playRecording(url: URL) {
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
    
    func deleteRecording(url: URL) {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
                if let index = audioRecorder.recordings.firstIndex(of: url) {
                    audioRecorder.recordings.remove(at: index)
                }
            } catch {
                print("Failed to delete recording: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at path: \(url.path)")
        }
    }
}
