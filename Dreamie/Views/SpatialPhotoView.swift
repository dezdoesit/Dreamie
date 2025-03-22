//
//  SpatialPhotoView.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//

import SwiftUI
import QuickLook
import UniformTypeIdentifiers

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
                    } label: {
                        Label("View in Spatial", systemImage: "eyes")
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                    .quickLookPreview($previewURL)
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
        let size = CGSize(width: 1024, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let colors: [UIColor] = [
                .systemBlue, .systemPurple, .systemPink
            ]
            
            let rect = CGRect(origin: .zero, size: size)
            
            // Create a gradient background
            let gradient = CAGradientLayer()
            gradient.frame = rect
            gradient.colors = colors.map { $0.cgColor }
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.render(in: context.cgContext)
            
            // Add some dream-like elements
            let numShapes = 20
            for _ in 0..<numShapes {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let diameter = CGFloat.random(in: 10...100)
                let opacity = CGFloat.random(in: 0.1...0.7)
                
                context.cgContext.setFillColor(UIColor.white.withAlphaComponent(opacity).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: x, y: y, width: diameter, height: diameter))
            }
            
            // Add text based on dream content
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .light),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8),
                .paragraphStyle: paragraphStyle
            ]
            
            // Extract some keywords from the dream
            let words = dream.content
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { $0.count > 4 }
                .prefix(5)
            
            let dreamText = words.joined(separator: " • ")
            dreamText.draw(
                with: CGRect(x: size.width * 0.1, y: size.height * 0.5 - 20, width: size.width * 0.8, height: 40),
                options: .usesLineFragmentOrigin,
                attributes: attributes,
                context: nil
            )
        }
        
        return image.pngData()
    }
}
