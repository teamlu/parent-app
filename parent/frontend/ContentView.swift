//
//  ContentView.swift
//  parent
//
//  Created by Tim Lu on 8/19/23.
//
import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State var isRecording = false
    @State var canSave = false
    @State var shouldSaveRecording = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Parent App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                RecordingsListView(audioRecorder: audioRecorder, shouldShow: $shouldSaveRecording)
                
                HStack {
                    Image(systemName: isRecording ? "stop.fill" : "record.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(isRecording ? .red : .gray)
                        .onTapGesture {
                            isRecording.toggle()
                            if isRecording {
                                audioRecorder.beginRecording()
                                canSave = true
                            } else {
                                audioRecorder.stopRecording()
                            }
                        }
                }
                .padding()
                
                Button("Save") {
                    shouldSaveRecording = true  // Show the recording list
                    audioRecorder.finalizeRecording()
                    audioRecorder.updateRecordingsList()  // Update the recordings list
                    canSave = false
                }
                .disabled(!canSave)
                .foregroundColor(canSave ? .blue : .gray)
                
                Text(audioRecorder.stopwatchText)
                    .font(.title)
                    .fontWeight(.medium)
                    .padding()
            }
        }
    }
}

struct RecordingsListView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Binding var shouldShow: Bool
    @State private var audioPlayer: AVAudioPlayer? = nil
    
    var body: some View {
        if shouldShow {
            List {
                ForEach(audioRecorder.recordings, id: \.self) { recordingURL in
                    NavigationLink(destination: RecordingDetails()) {
                        Text(recordingURL.lastPathComponent)
                    }
                    Spacer()
                    Button("Play") {
                        playRecording(url: recordingURL)
                    }
                    Button("Delete") {
                        deleteRecording(url: recordingURL)
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

struct RecordingDetails: View {
    var body: some View {
        Text("Recording Details")
            .navigationBarTitle("Details", displayMode: .inline)
            .navigationBarBackButtonHidden(false)
    }
}
