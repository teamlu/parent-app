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
    @State var recordingState: RecordingState = .idle
    @State var showSavedRecordings = false
    @State private var showSplash = true
    @State private var showParentAppText = false
    
    enum RecordingState {
        case idle
        case recording
        case paused
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if showParentAppText {
                        Text("Parent App")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                    }
                    
                    RecordingsListView(audioRecorder: audioRecorder, shouldShow: $showSavedRecordings)
                        .background(recordingState == .recording ? Color.black : Color(UIColor.secondarySystemBackground))
                        .disabled(recordingState == .recording)
                        .opacity(recordingState == .recording ? 0.4 : 1.0)
                    
                    if !showSplash {
                        HStack {
                            Image(systemName: recordingState == .recording ? "stop.fill" : "record.circle")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(recordingState == .recording ? .red : .gray)
                                .onTapGesture {
                                    switch recordingState {
                                    case .idle, .paused:
                                        recordingState = .recording
                                        audioRecorder.beginRecording()
                                    case .recording:
                                        recordingState = .paused
                                        audioRecorder.stopRecording()
                                    }
                                }
                            
                            Button("Save") {
                                showSavedRecordings = true
                                audioRecorder.finalizeRecording()
                                audioRecorder.updateRecordingsList()
                                recordingState = .idle
                            }
                            .disabled(recordingState != .paused)
                            .foregroundColor(recordingState == .paused ? .blue : .gray)
                            
                            Text(audioRecorder.stopwatchText)
                                .font(.title)
                                .fontWeight(.medium)
                                .padding()
                        }
                    }
                    
                    // Splash screen
                    if showSplash {
                        VStack {
                            Text("guardiin")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .background(Color.black)
                        .foregroundColor(Color.white)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    self.showSplash = false
                                    self.showParentAppText = true
                                }
                            }
                        }
                    }
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
    
    struct DadviceView: View {
        @State var currentIndex: Int // index to control the current display in the carousel
        var recordings: [URL] // Your array of recordings

        var body: some View {
            // Check if the currentIndex is within the valid range of the array
            if recordings.indices.contains(currentIndex) {
                NavigationView {
                    VStack {
                        Text("Dadvice")
                            .font(.title)
                            .padding()
                        
                        // Editable Recording Name
                        // Replace with your method to get recording name
                        TextField("Editable Recording Name", text: .constant("Recording \(currentIndex + 1)"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        HStack {
                            // Left Carousel Arrow
                            Button(action: {
                                withAnimation {
                                    currentIndex = max(currentIndex - 1, 0)
                                }
                            }) {
                                Image(systemName: "arrow.left.circle.fill")
                                    .font(.largeTitle)
                                    .opacity(currentIndex == 0 ? 0.4 : 1)
                            }
                            .disabled(currentIndex == 0)

                            VStack {
                                // Blue Rectangle
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.blue)
                                    .frame(height: 300)
                                    .overlay(
                                        Text("Your API-generated text here")
                                            .foregroundColor(.white)
                                            .padding()
                                    )
                            }

                            // Right Carousel Arrow
                            Button(action: {
                                withAnimation {
                                    currentIndex = min(currentIndex + 1, recordings.count - 1)
                                }
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.largeTitle)
                                    .opacity(currentIndex == recordings.count - 1 ? 0.4 : 1)
                            }
                            .disabled(currentIndex == recordings.count - 1)
                        }

                        Spacer()

                        // Share Icon (Bottom Right)
                        HStack {
                            Spacer()
                            Button(action: {
                                // Implement your sharing logic here
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(Circle().fill(Color.gray))
                            }
                        }
                    }
                    .navigationBarTitle("", displayMode: .inline)
                }
            }
        }
    }

    struct Recording: Identifiable {
        var id: String // Some unique id, could be the file URL
        var name: String // Recording name
        // Other properties such as Date, Status, etc.
    }
    
    class RecordingsManager: ObservableObject {
        @Published var recordings: [Recording] = [] // Populate this array as needed
    }
}
