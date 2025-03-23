//
//  SpatialPhotoView.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//

import SwiftUI
import QuickLook
import UniformTypeIdentifiers
import Photos

struct SpatialPhotoView: View {
    let dream: DreamEntry
    @Environment(SpatialPhotoViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isGenerating = false
    @State private var spatialPhoto: SpatialPhoto?
    @State private var previewURL: URL?
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Dream Visualization")
                .font(.largeTitle)
                .padding(.top)
            
            if let photo = spatialPhoto {
                // Spatial photo exists, allow viewing
                VStack(spacing: 16) {
                    Text("Your spatial photo is ready to view")
                        .font(.headline)
                    
                    Button {
                        previewURL = photo.url
                        
                        //SPAWN IN VIEW
                        Task {
                            print("Spawning?")
                            do{
                                await viewModel.SPAWNVIEW()
                            }
                        }

                    } label: {
                        Label("View in Spatial", systemImage: "eyes")
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                    
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            } else if isGenerating {
                // Currently generating
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    
                    Text("Creating your spatial photo...")
                        .font(.headline)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            } else {
                // Need to generate
                VStack(spacing: 16) {
                    Text("Transform your dream into a spatial photo")
                        .font(.headline)
                    
                    Text("Your dream will be transformed into a spatial photo that you can view in 3D on Apple Vision Pro.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Button {
                        generateSpatialPhoto()
                    } label: {
                        Label("Generate Spatial Photo", systemImage: "sparkles.rectangle.stack")
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            }
            
            // Dream details
            VStack(alignment: .leading, spacing: 12) {
                Text(dream.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(dream.date.formatted(date: .long, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                ScrollView {
                    Text(dream.content)
                        .padding(.vertical, 8)
                }
                .frame(maxHeight: 200)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Close")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(minWidth: 600, maxWidth: 700, minHeight: 700)
        .task {
            await loadExistingSpatialPhoto()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { showErrorAlert = false }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func loadExistingSpatialPhoto() async {
        spatialPhoto = await viewModel.getSpatialPhoto(for: dream.id)
    }
    
    private func generateSpatialPhoto() {
        Task {
            isGenerating = true
            defer { isGenerating = false }
            
            // In a real app, you would generate or retrieve an actual image here
            // For now, we'll create a simple gradient image as a placeholder
            if let imageData = createSampleImage() {
                spatialPhoto = await viewModel.createSpatialPhoto(from: imageData, for: dream.id)
                if spatialPhoto == nil {
                    errorMessage = viewModel.errorMessage
                    showErrorAlert = true
                }
            } else {
                
                errorMessage = "Failed to create sample image"
                showErrorAlert = true
            }
        }
    }
    
    // TEMPORARY: Creates a sample image for testing
    // In a real app, you would get this from your generative AI model
    private func createSampleImage() -> Data? {
        // Try to get the file URL for the resource
        if let fileURL = Bundle.main.url(forResource: "sample2", withExtension: "jpg") {
            print("MAKING PHOTO")
            do {
                // Read the file data directly
                let imageData = try Data(contentsOf: fileURL)
                return imageData
            } catch {
                print("Error loading HEIC file: \(error)")
            }
        }
        return nil
    }
}
