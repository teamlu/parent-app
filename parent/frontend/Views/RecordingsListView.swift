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
    
    var body: some View {
        if shouldShow {
            List {
                ForEach(viewModel.recordings, id: \.id) { recording in
                    // Initialize DadviceViewModel for each recording
                    let dadviceViewModel = viewModel.dadviceViewModel(for: recording)
                    
                    // Set up Navigation Link to DadviceView
                    NavigationLink(destination: DadviceView(viewModel: dadviceViewModel)) {
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(recording.name)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("\(recording.duration, specifier: "%.2f")s")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.black)
                            
                            HStack {
                                Text(recording.date, style: .date)
                                Spacer()
                                Image(systemName: "circle.fill")
                                    .foregroundColor(recording.status == .processing ? .orange : .green)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button("Play") {
                            viewModel.playRecording(recording: recording)
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete") {
                            viewModel.deleteRecording(recording: recording)
                        }
                        .tint(.red)
                    }
                }
            }
        }
    }
}
