//
//  SpatialPhotoModel.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//

import Foundation
import SwiftUI

/// Represents a spatial photo associated with a dream entry
struct SpatialPhoto: Identifiable, Codable {
    var id: UUID = UUID()
    var dreamId: UUID  // Associated dream entry
    var url: URL       // URL to the spatial photo file
    var createdAt: Date = Date()
    
    init(dreamId: UUID, url: URL) {
        self.dreamId = dreamId
        self.url = url
    }
}

/// Service to manage spatial photos
actor SpatialPhotoService {
    private let fileManager = FileManager.default
    private var documentsDirectory: URL {
        try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    private var spatialPhotosFolder: URL {
        let folder = documentsDirectory.appendingPathComponent("SpatialPhotos", isDirectory: true)
        if !fileManager.fileExists(atPath: folder.path()) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }
    private var metadataFileURL: URL {
        documentsDirectory.appendingPathComponent("spatial_photos.json")
    }
    
    /// Save a spatial photo to the app's document directory
    /// - Parameters:
    ///   - spatialPhotoURL: Source URL of the spatial photo
    ///   - dreamId: ID of the associated dream
    /// - Returns: A SpatialPhoto object with storage details
    func saveSpatialPhoto(from spatialPhotoURL: URL, for dreamId: UUID) async throws -> SpatialPhoto {
        // Create a permanent file path in the app's document directory
        let fileName = "spatial_\(dreamId.uuidString).heic"
        let destinationURL = spatialPhotosFolder.appendingPathComponent(fileName)
        
        // Copy the spatial photo to the app's documents directory
        if fileManager.fileExists(atPath: destinationURL.path()) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.copyItem(at: spatialPhotoURL, to: destinationURL)
        
        // Create and save the metadata
        let spatialPhoto = SpatialPhoto(dreamId: dreamId, url: destinationURL)
        var photos = try await loadSpatialPhotos()
        
        // Remove any existing photo for this dream
        photos.removeAll { $0.dreamId == dreamId }
        
        // Add the new photo
        photos.append(spatialPhoto)
        try await saveSpatialPhotoMetadata(photos)
        
        return spatialPhoto
    }
    
    /// Load all spatial photos metadata
    func loadSpatialPhotos() async throws -> [SpatialPhoto] {
        guard fileManager.fileExists(atPath: metadataFileURL.path()) else {
            return []
        }
        
        let data = try Data(contentsOf: metadataFileURL)
        return try JSONDecoder().decode([SpatialPhoto].self, from: data)
    }
    
    /// Get a spatial photo for a specific dream
    func getSpatialPhoto(for dreamId: UUID) async throws -> SpatialPhoto? {
        let photos = try await loadSpatialPhotos()
        return photos.first { $0.dreamId == dreamId }
    }
    
    /// Delete a spatial photo
    func deleteSpatialPhoto(with id: UUID) async throws {
        var photos = try await loadSpatialPhotos()
        guard let photoIndex = photos.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let photo = photos[photoIndex]
        
        // Delete the file
        if fileManager.fileExists(atPath: photo.url.path()) {
            try fileManager.removeItem(at: photo.url)
        }
        
        // Update metadata
        photos.remove(at: photoIndex)
        try await saveSpatialPhotoMetadata(photos)
    }
    
    /// Delete all spatial photos associated with a dream
    func deleteSpatialPhotos(for dreamId: UUID) async throws {
        var photos = try await loadSpatialPhotos()
        let dreamPhotos = photos.filter { $0.dreamId == dreamId }
        
        // Delete all files
        for photo in dreamPhotos {
            if fileManager.fileExists(atPath: photo.url.path()) {
                try fileManager.removeItem(at: photo.url)
            }
        }
        
        // Update metadata
        photos.removeAll { $0.dreamId == dreamId }
        try await saveSpatialPhotoMetadata(photos)
    }
    
    /// Save metadata for all spatial photos
    private func saveSpatialPhotoMetadata(_ photos: [SpatialPhoto]) async throws {
        let data = try JSONEncoder().encode(photos)
        try data.write(to: metadataFileURL)
    }
}
