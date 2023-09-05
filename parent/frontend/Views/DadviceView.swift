//
//  DadviceView.swift
//  parent
//
//  Created by Tim Lu on 9/4/23.
//

import SwiftUI

struct DadviceView: View {
    @ObservedObject var viewModel: DadviceViewModel
    @State private var tempName: String = ""
    @State private var isEditing: Bool = false
    @State private var offset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Dadvice")
                        .font(.largeTitle)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                    
                    HStack {
                        if !isEditing {
                            Text(viewModel.currentRecording?.name ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: { isEditing = true }) {
                                Image(systemName: "pencil")
                            }
                        } else {
                            TextField("Recording Name", text: $tempName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Save") {
                                if let recording = viewModel.currentRecording {
                                    recording.name = tempName
                                    viewModel.onRecordingUpdated?(recording)
                                }
                                isEditing = false
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        self.tempName = viewModel.currentRecording?.name ?? ""
                    }
                    .onReceive(viewModel.$currentRecording) { newRecording in
                        tempName = newRecording?.name ?? ""
                    }
                    
                    HStack {
                        // Left Carousel Arrow
                        Button(action: {
                            withAnimation {
                                offset += 400
                                viewModel.moveToPrevious()
                            }
                        }) {
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
                                .offset(x: offset)
                        }
                        
                        // Right Carousel Arrow
                        Button(action: {
                            withAnimation {
                                offset -= 400
                                viewModel.moveToNext()
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.largeTitle)
                                .opacity(viewModel.currentIndex == viewModel.recordings.count - 1 ? 0.4 : 1)
                        }
                        .disabled(viewModel.currentIndex == viewModel.recordings.count - 1)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                offset = 0
                            }
                        }
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
            }
            .navigationBarHidden(true)
        }
    }
}
