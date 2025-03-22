//
//  SpatialPhotoViewModel.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//

import Foundation
import SwiftUI
import Photos

@MainActor
@Observable
class SpatialPhotoViewModel {
    private let photoService = SpatialPhotoService()
    private let converter = SpatialPhotoConverter()
    
    var isProcessing = false
    var spatialPhotos: [SpatialPhoto] = []
    var errorMessage: String?
    
    init() {
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
    func createSpatialPhoto(from imageData: Data, for dreamId: UUID) async -> SpatialPhoto? {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            // Convert the image to a spatial photo
            let spatialPhotoURL = try await converter.convertToSpatialPhoto(inputImage: imageData)
            
            // Save the spatial photo and its metadata
            let spatialPhoto = try await photoService.saveSpatialPhoto(from: spatialPhotoURL, for: dreamId)
            
            // Reload the list of spatial photos
            await loadSpatialPhotos()
            
            return spatialPhoto
        } catch {
            errorMessage = "Failed to create spatial photo: \(error.localizedDescription)"
            return nil
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
    
    /// Deletes all spatial photos associated with a dream entry
    /// - Parameter dreamId: The ID of the dream entry
    func deleteSpatialPhotos(for dreamId: UUID) async {
        do {
            try await photoService.deleteSpatialPhotos(for: dreamId)
            await loadSpatialPhotos()
        } catch {
            errorMessage = "Failed to delete spatial photos: \(error.localizedDescription)"
        }
    }
}
