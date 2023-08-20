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
    
    var body: some Scene {
        WindowGroup {
            ContentView(audioRecorder: audioRecorder) // Pass the instance to ContentView
        }
    }
}
