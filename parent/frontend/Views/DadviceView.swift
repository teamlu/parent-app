//
//  DadviceView.swift
//  parent
//
//  Created by Tim Lu on 8/19/23.
//

import SwiftUI

struct DadviceView: View {
    @ObservedObject var viewModel: DadviceViewModel
    @State private var tempName: String = ""
    @State private var isEditing: Bool = false
    @State private var offset: CGFloat = 0
    
    init(viewModel: DadviceViewModel) {
        self.viewModel = viewModel
        
        // Set initial offset based on the current index
        self._offset = State(initialValue: -CGFloat(viewModel.currentIndex * 275))
        self._tempName = State(initialValue: viewModel.currentRecording?.name ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color for the entire screen
                Color(UIColor.secondarySystemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    // Dadvice Header
                    Text("Dadvice")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    // Recording Name
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
                                    viewModel.saveChanges(for: recording)  // Use the updated method
                                }
                                isEditing = false
                            }                        }
                    }
                    .padding([.leading, .trailing])
                    .padding(.top, 10)
                    
                    // Carousel
                    HStack {
                        // Left Carousel Arrow
                        Button(action: {
                            withAnimation {
                                viewModel.moveToPrevious()
                                self.offset += 275
                            }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.largeTitle)
                        }
                        .disabled(viewModel.atBeginning)
                       
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 25) {
                                ForEach(0..<viewModel.recordingObjects.count, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.blue)
                                        .frame(width: 250, height: 400)
                                        .overlay(
                                            Text(viewModel.recordingObjects[index].adviceText ?? "Loading advice...")
                                                .foregroundColor(.white)
                                                .padding()
                                        )
                                }
                            }
                            .offset(x: self.offset)
                        }
                        
                        // Right Carousel Arrow
                        Button(action: {
                            withAnimation {
                                viewModel.moveToNext()
                                self.offset -= 275
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.largeTitle)
                        }
                        .disabled(viewModel.atEnd)
                    }
                    
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
                    .padding(.bottom)
                }
                .padding([.leading, .trailing])
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            tempName = viewModel.currentRecording?.name ?? ""
            print("onAppear: Current index is \(viewModel.currentIndex)") // Debug

        }
        .onChange(of: viewModel.currentIndex) { newIndex in
            print("onChange: Current index has changed to \(newIndex)") // Debug
            // Update the offset and tempName whenever currentIndex changes
            self.offset = -CGFloat(newIndex * 275)
            self.tempName = viewModel.currentRecording?.name ?? ""
        }
    }
}
