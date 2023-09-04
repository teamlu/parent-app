//
//  RecordingsListView.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//

import SwiftUI
import AVFoundation

struct RecordingsListView: View {
    @ObservedObject var viewModel: RecordingsListViewModel
    @Binding var shouldShow: Bool
    @State private var audioPlayer: AVAudioPlayer? = nil
    
    var body: some View {
        if shouldShow {
            List {
                ForEach(viewModel.audioRecorder.recordings, id: \.self) { recordingURL in
                    let index = viewModel.audioRecorder.recordings.firstIndex(of: recordingURL) ?? 0
                    let dadviceViewModel = DadviceViewModel(currentIndex: index, recordings: viewModel.audioRecorder.recordings)

                    NavigationLink(destination: DadviceView(viewModel: dadviceViewModel)) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Recording \(index + 1)")
                                    .fontWeight(.bold)
                                Spacer()
                                Text(viewModel.audioRecorder.getDurationWrapper(for: recordingURL))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.black)
                            
                            HStack {
                                Text(viewModel.audioRecorder.getDateWrapper(for: recordingURL))
                                Spacer()
                                Image(systemName: "circle.fill")
                                    .foregroundColor(viewModel.audioRecorder.getStatusWrapper(for: recordingURL) == .Processing ? .orange : .green) // Updated this line
                                Text(viewModel.audioRecorder.getStatusWrapper(for: recordingURL).rawValue)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button("Play") {
                            viewModel.playRecording(url: recordingURL)
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete") {
                            viewModel.deleteRecording(url: recordingURL)
                        }
                        .tint(.red)
                    }
                }
            }
        }
    }
}
