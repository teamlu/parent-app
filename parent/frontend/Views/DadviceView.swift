//
//  DadviceView.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//

import SwiftUI

struct DadviceView: View {
    @State var currentIndex: Int // index to control the current display in the carousel
    var recordings: [URL] // Your array of recordings

    var body: some View {
        // Check if the currentIndex is within the valid range of the array
        if recordings.indices.contains(currentIndex) {
            NavigationView {
                VStack {
                    Text("Dadvice")
                        .font(.title)
                        .padding()
                    
                    // Editable Recording Name
                    // Replace with your method to get recording name
                    TextField("Editable Recording Name", text: .constant("Recording \(currentIndex + 1)"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    HStack {
                        // Left Carousel Arrow
                        Button(action: {
                            withAnimation {
                                currentIndex = max(currentIndex - 1, 0)
                            }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.largeTitle)
                                .opacity(currentIndex == 0 ? 0.4 : 1)
                        }
                        .disabled(currentIndex == 0)

                        VStack {
                            // Blue Rectangle
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                                .frame(height: 300)
                                .overlay(
                                    Text("Your API-generated text here")
                                        .foregroundColor(.white)
                                        .padding()
                                )
                        }

                        // Right Carousel Arrow
                        Button(action: {
                            withAnimation {
                                currentIndex = min(currentIndex + 1, recordings.count - 1)
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.largeTitle)
                                .opacity(currentIndex == recordings.count - 1 ? 0.4 : 1)
                        }
                        .disabled(currentIndex == recordings.count - 1)
                    }

                    Spacer()

                    // Share Icon (Bottom Right)
                    HStack {
                        Spacer()
                        Button(action: {
                            // Implement your sharing logic here
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Circle().fill(Color.gray))
                        }
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
            }
        }
    }
}
