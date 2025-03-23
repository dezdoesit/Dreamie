//
//  DreamRecordingView.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//

// DreamRecordingView.swift
import SwiftUI

struct DreamRecordingView: View {
    @Environment(DreamViewModel.self) private var viewModel
    @State private var showingSaveDialog = false
    
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.purple.opacity(0.8),
                    Color.black
                ]),
                center: .center,
                startRadius: 560,
                endRadius: 880
            )
            .edgesIgnoringSafeArea(.all)
        VStack(spacing: 20) {
            Text("Record Your Dream")
                .font(.largeTitle)
                .padding(.top)
            
            if viewModel.authorizationStatus != .authorized {
                Text("Speech recognition permission is required")
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(viewModel.transcribedText.isEmpty ? "Your dream will appear here..." : viewModel.transcribedText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal)
                    }
                }
                .frame(maxHeight: 300)
                
                Button {
                    Task {
                        await viewModel.toggleRecording()
                    }
                } label: {
                    Label(viewModel.recordingStatus, systemImage: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                        .padding()

                        
                }
                .background(
                    viewModel.isRecording
                    ? Color.red.opacity(0.2)  // Red background when recording
                    : Color.purple.opacity(0.8)  // Purple background when not recording
                )
                .cornerRadius(15)
                .frame(maxWidth: .infinity, minHeight: 60)
                .disabled(viewModel.authorizationStatus != .authorized)
                
                if !viewModel.transcribedText.isEmpty {
                    HStack(spacing: 20) {
                        Button {
                            showingSaveDialog = true
                        } label: {
                            Label("Save Dream", systemImage: "square.and.arrow.down")
                                .padding()
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(15)
                        }
                        
                        Button {
                            viewModel.resetCurrentDream()
                        } label: {
                            Label("Clear", systemImage: "trash")
                                .padding()
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(15)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingSaveDialog) {
            SaveDreamView()
        }
        .padding()
    }
    }
}
