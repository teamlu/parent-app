//
//  Recording.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//

import Foundation
import SwiftUI // Make sure to import this

enum RecordingStatus {
    case completed
    case processing
}

class Recording: Identifiable, ObservableObject {
    var id: UUID
    @Published var name: String
    var date: Date
    var duration: Double
    var status: RecordingStatus
    var url: URL

    init(id: UUID, name: String, date: Date, duration: Double, status: RecordingStatus, url: URL) {
        self.id = id
        self.name = name
        self.date = date
        self.duration = duration
        self.status = status
        self.url = url
    }
}
