//
//  AudioFileUtility.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//

import Foundation
import AVFoundation

class AudioFileUtility {
    
    // This function takes a TimeInterval and returns a formatted String
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
    
    func getDuration(for url: URL) -> Double {
        var duration: Double = 0
        do {
            let audioAsset = try AVAudioPlayer(contentsOf: url)
            duration = audioAsset.duration
        } catch {
            print("Could not load file for duration: \(error.localizedDescription)")
        }
        return duration
    }

    func getDate(for url: URL) -> String {
        // TODO: Implement the logic to get date of the audio file
        return "yyyy/MM/dd"
    }

    // THis is duplicated in Recording model
    enum RecordingStatus: String {
        case Processing = "Processing"
        case Done = "Done"
        // Add more status if needed
    }

    func getStatus(for url: URL) -> RecordingStatus {
        // TODO: Implement the logic to get status of the audio file
        return .Done
    }
}
