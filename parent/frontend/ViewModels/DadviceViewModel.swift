//
//  DadviceViewModel.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//

import Foundation
import Combine
import SwiftUI

class DadviceViewModel: ObservableObject {
    @Published var currentIndex: Int // Index to control the current display in the carousel
    @Published var adviceText: String = "Loading advice..."
    
    var recordings: [URL] // Your array of recordings
    private var cancellables: Set<AnyCancellable> = []
    
    init(currentIndex: Int, recordings: [URL]) {
        self.currentIndex = currentIndex
        self.recordings = recordings
        fetchDadAdvice()
    }
    
    // Function to fetch Dad advice from an API
    // You can replace this function with an actual API call
    func fetchDadAdvice() {
        // Simulated API call, replace with your own API logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.adviceText = "Always remember to tie your shoes."
        }
    }
    
    // Function to move to the previous recording
    func moveToPrevious() {
        withAnimation {
            currentIndex = max(currentIndex - 1, 0)
        }
    }
    
    // Function to move to the next recording
    func moveToNext() {
        withAnimation {
            currentIndex = min(currentIndex + 1, recordings.count - 1)
        }
    }
    
    // Function to share content
    // You can add sharing logic here
    func shareContent() {
        // Your sharing logic
    }
}
