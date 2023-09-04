//
//  AudioFileManager.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//
import Foundation
import AVFoundation

class AudioFileManager {
    
    func generateUniqueFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return "recording_\(dateFormatter.string(from: Date())).m4a"
    }
    
    func prepareRecorder(uniqueName: String) -> AVAudioRecorder? {
        let url = getDocumentsDirectory().appendingPathComponent(uniqueName)
        var audioRecorder: AVAudioRecorder?
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.prepareToRecord()
        } catch {
            print("Failed to set up audio recorder: \(error)")
        }
        
        return audioRecorder
    }
    
    func fetchRecordings() -> [URL] {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: [])
            let audioFiles = directoryContents.filter { $0.pathExtension == "m4a" }
            
            return audioFiles.sorted(by: {
                do {
                    let attributes1 = try FileManager.default.attributesOfItem(atPath: $0.path) as NSDictionary
                    let attributes2 = try FileManager.default.attributesOfItem(atPath: $1.path) as NSDictionary
                    
                    let creationDate1 = attributes1.fileCreationDate()!
                    let creationDate2 = attributes2.fileCreationDate()!
                    
                    return creationDate1.compare(creationDate2) == .orderedAscending
                } catch {
                    print("Error sorting recordings: \(error)")
                    return false
                }
            })
        } catch {
            print("Could not fetch recordings: \(error)")
            return []
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
