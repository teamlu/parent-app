//
//  parentApp.swift
//  parent
//
//  Created by Tim Lu on 8/19/23.
//

import SwiftUI

@main
struct parentApp: App {
    var audioRecorder = AudioRecorder() // Create an instance of AudioRecorder
    var viewModel: ContentViewModel // Create an instance of ContentViewModel
    
    init() {
        viewModel = ContentViewModel(audioRecorder: audioRecorder)
        audioRecorder.updateRecordingsList() // Initialize the recordings list
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel, audioRecorder: audioRecorder) // Pass the instances to ContentView
        }
    }
}
