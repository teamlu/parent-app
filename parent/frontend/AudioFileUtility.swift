//
//  AudioFileUtility.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//

import Foundation

class AudioFileUtility {
    
    // This function takes a TimeInterval and returns a formatted String
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
 
    func getDuration(for url: URL) -> String {
        // TODO: Implement the logic to get duration of the audio file
        return "00:00"
    }

    func getDate(for url: URL) -> String {
        // TODO: Implement the logic to get date of the audio file
        return "yyyy/MM/dd"
    }

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
