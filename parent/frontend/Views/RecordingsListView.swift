//
//  RecordingsListView.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//
//

import SwiftUI
import AVFoundation

struct RecordingsListView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Binding var shouldShow: Bool
    @State private var audioPlayer: AVAudioPlayer? = nil
    
    var body: some View {
        if shouldShow {
            List {
                ForEach(audioRecorder.recordings, id: \.self) { recordingURL in
                    let index = audioRecorder.recordings.firstIndex(of: recordingURL) ?? 0
                    
                    NavigationLink(destination: DadviceView(currentIndex: index, recordings: audioRecorder.recordings)) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Recording \(index + 1)")
                                    .fontWeight(.bold)
                                Spacer()
                                Text(audioRecorder.getDurationWrapper(for: recordingURL))  // Updated this line
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.black)
                            
                            HStack {
                                Text(audioRecorder.getDateWrapper(for: recordingURL))  // Updated this line
                                Spacer()
                                Image(systemName: "circle.fill")
                                    .foregroundColor(audioRecorder.getStatusWrapper(for: recordingURL) == .Processing ? .orange : .green) // Updated this line
                                Text(audioRecorder.getStatusWrapper(for: recordingURL).rawValue)  // Updated this line
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button("Play") {
                            playRecording(url: recordingURL)
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete") {
                            deleteRecording(url: recordingURL)
                        }
                        .tint(.red)
                    }
                }
            }
        }
    }
    
    private func playRecording(url: URL) {
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
    
    private func deleteRecording(url: URL) {
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
