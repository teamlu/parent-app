//
//  RecordingsListView.swift
//  parent
//
//  Created by Tim Lu on 8/20/23.
//
import SwiftUI
import AVFoundation

struct RecordingsListView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        List {
            ForEach(audioRecorder.recordings, id: \.self) { recording in
                HStack {
                    Text(recording.lastPathComponent)
                        .onTapGesture {
                            playRecording(url: recording)
                        }
                    
                    Spacer()
                    
                    Button(action: {
                        deleteRecording(url: recording)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationBarTitle("All Recordings", displayMode: .inline)
        .onDisappear {
            // Stop the audio playback when the view is about to disappear
            stopPlayback()
        }
    }

    private func playRecording(url: URL) {
        print("Attempting to play file at URL: \(url.path)")

        if FileManager.default.fileExists(atPath: url.path) {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playback, mode: .default)
                try session.setActive(true)

                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay() // Preloading buffer
                audioPlayer?.volume = 1.0 // Setting volume
                audioPlayer?.play()
            } catch {
                print("Couldn't load the audio file: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at path: \(url.path)")
        }
    }
    
    private func deleteRecording(url: URL) {
        // Stop the audio player if it's playing
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
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
}

