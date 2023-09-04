//
//  ContentView.swift
//  parent
//
//  Created by Tim Lu on 8/19/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if viewModel.showParentAppText {
                        Text("Parent App")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                    }
                    
                    RecordingsListView(viewModel: RecordingsListViewModel(audioRecorder: audioRecorder), shouldShow: $viewModel.showSavedRecordings)
                        .background(viewModel.recordingState == .recording ? Color.black : Color(UIColor.secondarySystemBackground))
                        .disabled(viewModel.recordingState == .recording)
                        .opacity(viewModel.recordingState == .recording ? 0.4 : 1.0)
                    
                    if !viewModel.showSplash {
                        HStack {
                            Image(systemName: viewModel.recordingState == .recording ? "stop.fill" : "record.circle")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(viewModel.recordingState == .recording ? .red : .gray)
                                .onTapGesture {
                                    viewModel.toggleRecording()
                                }
                            
                            Button("Save") {
                                viewModel.saveRecording()
                            }
                            .disabled(viewModel.recordingState != .paused)
                            .foregroundColor(viewModel.recordingState == .paused ? .blue : .gray)
                            
                            Text(audioRecorder.stopwatchText)
                                .font(.title)
                                .fontWeight(.medium)
                                .padding()
                        }
                    }
                    
                    // Splash screen
                    if viewModel.showSplash {
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
                            viewModel.handleSplashScreen()
                        }
                    }
                }
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
