//
//  SpatialPhotoViewModel.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//

import Foundation
import SwiftUI
import Photos
import QuickLook

@MainActor
@Observable
class SpatialPhotoViewModel {
    private let photoService = SpatialPhotoService()
    private let converter = SpatialPhotoConverter()
    
    var isProcessing = false
    var spatialPhotos: [SpatialPhoto] = []
    var errorMessage: String?
    var spawnView: URL?
    private let dreamStorage: DreamStorageService
    
    init(dreamStorage: DreamStorageService) {
        self.dreamStorage = dreamStorage
        Task {
            await loadSpatialPhotos()
        }
            
        }

    
    
    /// Loads all spatial photos from storage
    func loadSpatialPhotos() async {
        do {
            spatialPhotos = try await photoService.loadSpatialPhotos()
        } catch {
            errorMessage = "Failed to load spatial photos: \(error.localizedDescription)"
        }
    }
    
    /// Creates a spatial photo from image data and associates it with a dream entry
    /// - Parameters:
    ///   - imageData: The source image data
    ///   - dreamId: The ID of the associated dream entry
    /// - Returns: The created spatial photo or nil if creation failed
    ///
    func SPAWNVIEW() async {
        print("SPAWNVIEW1", spawnView!)
        try? await PreviewApplication.open(urls: [spawnView!])
    }
    func saveStory(Story: String, for dreamID: UUID) async -> Void{
        do{
            try await dreamStorage.updateStory(id: dreamID, Story: Story)
           
        }catch{
            print(error.localizedDescription)
        }
    }
    func createSpatialPhoto(from imageData: Data, for dreamId: UUID) async -> SpatialPhoto? {
            isProcessing = true
            defer { isProcessing = false }
            
            do {
                let spatialPhotoURL = try await converter.convertToSpatialPhoto(inputImage: imageData)
                spawnView = spatialPhotoURL
                saveToPhotoLibrary(from: spatialPhotoURL)
                
                let spatialPhoto = try await photoService.saveSpatialPhoto(from: spatialPhotoURL, for: dreamId)
                
                // Update the dream entry with the new spatial photo data and URL
                try await dreamStorage.updateDream(id: dreamId, spatialPhotoData: imageData, spatialPhotoURL: spatialPhotoURL.absoluteString)
                
                await loadSpatialPhotos()
                
                return spatialPhoto
            } catch {
                errorMessage = "Failed to create spatial photo: \(error.localizedDescription)"
                return nil
            }
        }
    private func saveToPhotoLibrary(from url: URL) {
        // Request authorization to access the photo library
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                // Save the image to the photo library WITH metadata intact
                PHPhotoLibrary.shared().performChanges({
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, fileURL: url, options: nil)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self.errorMessage = "Spatial image saved successfully!"
                        } else if let error = error {
                            self.errorMessage = "Failed to save: \(error.localizedDescription)"
                        }
                    }
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.errorMessage = "Access to photo library is denied"
                }
            case .notDetermined, .limited:
                DispatchQueue.main.async {
                    self.errorMessage = "Access to photo library not determined"
                }
            @unknown default:
                DispatchQueue.main.async {
                    self.errorMessage = "Unknown error accessing photo library"
                }
            }
        }
    }
    
    /// Gets a spatial photo for a specific dream entry
    /// - Parameter dreamId: The ID of the dream entry
    /// - Returns: The associated spatial photo, if any
    func getSpatialPhoto(for dreamId: UUID) async -> SpatialPhoto? {
        do {
            return try await photoService.getSpatialPhoto(for: dreamId)
        } catch {
            errorMessage = "Failed to get spatial photo: \(error.localizedDescription)"
            return nil
        }
    }
    
    /// Deletes a spatial photo
    /// - Parameter id: The ID of the spatial photo to delete
    func deleteSpatialPhoto(with id: UUID) async {
        do {
            try await photoService.deleteSpatialPhoto(with: id)
            await loadSpatialPhotos()
        } catch {
            errorMessage = "Failed to delete spatial photo: \(error.localizedDescription)"
        }
    }
}
