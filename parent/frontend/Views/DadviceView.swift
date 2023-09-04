//
//  DadviceView.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//

import SwiftUI

struct DadviceView: View {
    @ObservedObject var viewModel: DadviceViewModel

    var body: some View {
        // Check if the currentIndex is within the valid range of the array
        if viewModel.recordings.indices.contains(viewModel.currentIndex) {
            NavigationView {
                VStack {
                    Text("Dadvice")
                        .font(.title)
                        .padding()
                    
                    // Editable Recording Name
                    // Replace with your method to get recording name
                    TextField("Editable Recording Name", text: .constant("Recording \(viewModel.currentIndex + 1)"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    HStack {
                        // Left Carousel Arrow
                        Button(action: viewModel.moveToPrevious) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.largeTitle)
                                .opacity(viewModel.currentIndex == 0 ? 0.4 : 1)
                        }
                        .disabled(viewModel.currentIndex == 0)

                        VStack {
                            // Blue Rectangle
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                                .frame(height: 300)
                                .overlay(
                                    Text(viewModel.adviceText)
                                        .foregroundColor(.white)
                                        .padding()
                                )
                        }

                        // Right Carousel Arrow
                        Button(action: viewModel.moveToNext) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.largeTitle)
                                .opacity(viewModel.currentIndex == viewModel.recordings.count - 1 ? 0.4 : 1)
                        }
                        .disabled(viewModel.currentIndex == viewModel.recordings.count - 1)
                    }

                    Spacer()

                    // Share Icon (Bottom Right)
                    HStack {
                        Spacer()
                        Button(action: viewModel.shareContent) {
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
