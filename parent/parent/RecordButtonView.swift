//
//  RecordButtonView.swift
//  parent
//
//  Created by Tim Lu on 8/20/23.
//
import UIKit

class RecordButton: UIButton {
    var isRecording: Bool = false {
        didSet {
            // Customize appearance based on recording status.
            // For example, you might change the button's title or color.
            setTitle(isRecording ? "Stop" : "Record", for: .normal)
            backgroundColor = isRecording ? .red : .green
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initial appearance customization
        setTitle("Record", for: .normal)
        backgroundColor = .green
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

import SwiftUI

struct RecordButtonView: UIViewRepresentable {
    @Binding var isRecording: Bool
    var audioRecorder: AudioRecorder

    func makeUIView(context: Context) -> RecordButton {
        let button = RecordButton()
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleRecording(_:)), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: RecordButton, context: Context) {
        uiView.isRecording = isRecording
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, audioRecorder: audioRecorder)
    }

    class Coordinator: NSObject {
        var parent: RecordButtonView
        var audioRecorder: AudioRecorder
        
        init(_ parent: RecordButtonView, audioRecorder: AudioRecorder) {
            self.parent = parent
            self.audioRecorder = audioRecorder
        }

        @objc func handleRecording(_ sender: RecordButton) {
            parent.isRecording.toggle()
            if parent.isRecording {
                audioRecorder.startRecording()
            } else {
                audioRecorder.stopRecording()
            }
        }
    }
}
