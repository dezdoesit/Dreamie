
/*
 SpatialPhotoConverter.swift
 Dreamie
 
 Created by Dezmond Blair on 3/22/25.
 
 Converts a single image into a spatial photo by creating a stereo pair
 with appropriate spatial metadata.
*/

import Foundation
import ImageIO
import UniformTypeIdentifiers
import SwiftUI

/// Converts a single image into a stereo pair with spatial metadata to create a spatial photo.
actor SpatialPhotoConverter {
    
    // Default parameters for spatial photo creation
    private let defaultBaselineInMillimeters: Double = 64.0  // Standard human IPD
    private let defaultHorizontalFOV: Double = 80.0
    private let defaultDisparityAdjustment: Double = 0.02    // 2% positive disparity
    
    /// A 3x3 identity rotation matrix.
    private let identityRotation: [Double] = [
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    ]
    
    /// Converts a single image into a spatial photo by creating a stereo pair
    /// - Parameters:
    ///   - inputImage: Original image data
    ///   - outputURL: URL where the spatial photo will be saved
    /// - Returns: URL of the created spatial photo
    func convertToSpatialPhoto(inputImage: Data, outputURL: URL? = nil) async throws -> URL {
        // Create a temporary file URL if none provided
        let finalOutputURL = outputURL ?? FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("heic")
        
        // Create left and right image pairs with a slight horizontal offset
        let (leftImageURL, rightImageURL) = try await createStereoPair(from: inputImage)
        
        // Delete the output file if it already exists
        if FileManager.default.fileExists(atPath: finalOutputURL.path()) {
            try FileManager.default.removeItem(at: finalOutputURL)
        }
        
        // Create the spatial photo
        try await convertStereoToSpatial(
            leftImageURL: leftImageURL,
            rightImageURL: rightImageURL,
            outputImageURL: finalOutputURL,
            baselineInMillimeters: defaultBaselineInMillimeters,
            horizontalFOV: defaultHorizontalFOV,
            disparityAdjustment: defaultDisparityAdjustment
        )
        
        // Clean up temporary files
        try? FileManager.default.removeItem(at: leftImageURL)
        try? FileManager.default.removeItem(at: rightImageURL)
        
        return finalOutputURL
    }
    
    /// Creates a stereo pair of images from a single image by creating a slightly offset version
    /// for the right eye
    /// - Parameter imageData: The original image data
    /// - Returns: URLs for left and right image files
    private func createStereoPair(from imageData: Data) async throws -> (URL, URL) {
        // Create temporary URLs for the left and right images
        let leftImageURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("left_\(UUID().uuidString)")
            .appendingPathExtension("png")
        
        let rightImageURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("right_\(UUID().uuidString)")
            .appendingPathExtension("png")
        
        // For now, we'll use the same image for both left and right
        // In a production app, you would create an offset version for the right eye
        // using Core Image or other image processing techniques
        try imageData.write(to: leftImageURL)
        try imageData.write(to: rightImageURL)
        
        // In a more sophisticated implementation, you would:
        // 1. Load the image into a CIImage
        // 2. Apply a slight horizontal offset transform for the right eye
        // 3. Render and save each image separately
        
        return (leftImageURL, rightImageURL)
    }
    
    /// Converts a left- and right-eye image, plus spatial metadata, into a spatial photo.
    private func convertStereoToSpatial(
        leftImageURL: URL,
        rightImageURL: URL,
        outputImageURL: URL,
        baselineInMillimeters: Double,
        horizontalFOV: Double,
        disparityAdjustment: Double
    ) async throws {
        // Open both images
        let leftImage = try await openImageSource(url: leftImageURL)
        let rightImage = try await openImageSource(url: rightImageURL)
        
        // Validate that both images are the same size
        guard leftImage.width == rightImage.width, leftImage.height == rightImage.height else {
            throw SpatialPhotoError.imagesNotSameSize
        }
        
        // Convert the baseline from millimeters to meters
        let baselineInMeters = baselineInMillimeters / 1000.0
        
        // Define a pair of extrinsic positions that describe how the two cameras are positioned
        // relative to each other in 3D space
        let leftPosition: [Double] = [0, 0, 0]
        let rightPosition: [Double] = [baselineInMeters, 0, 0]
        
        // Calculate an intrinsics matrix for both cameras
        let intrinsics = calculateIntrinsics(
            width: leftImage.width,
            height: leftImage.height,
            horizontalFOV: horizontalFOV
        )
        
        // Encode the provided floating-point disparity adjustment
        // into the integer form expected by the spatial photo format
        let encodedDisparityAdjustment = Int(disparityAdjustment * 1e4)
        
        // Create property dictionaries
        let leftProperties = propertiesDictionary(
            isLeft: true,
            encodedDisparityAdjustment: encodedDisparityAdjustment,
            position: leftPosition,
            intrinsics: intrinsics
        )
        
        let rightProperties = propertiesDictionary(
            isLeft: false,
            encodedDisparityAdjustment: encodedDisparityAdjustment,
            position: rightPosition,
            intrinsics: intrinsics
        )
        
        // Create a HEIC image destination at the provided output URL
        let destinationProperties: [CFString: Any] = [kCGImagePropertyPrimaryImage: 0]
        guard let destination = CGImageDestinationCreateWithURL(
            outputImageURL as CFURL,
            UTType.heic.description as CFString,
            2,
            destinationProperties as CFDictionary
        ) else {
            throw SpatialPhotoError.unableToCreateImageDestination
        }
        
        // Add the left and right images to the destination with appropriate properties
        CGImageDestinationAddImageFromSource(
            destination,
            leftImage.source,
            leftImage.primaryImageIndex,
            leftProperties as CFDictionary
        )
        
        CGImageDestinationAddImageFromSource(
            destination,
            rightImage.source,
            rightImage.primaryImageIndex,
            rightProperties as CFDictionary
        )
        
        // Finalize the image destination to write the spatial photo to disk
        guard CGImageDestinationFinalize(destination) else {
            throw SpatialPhotoError.unableToFinalizeImageDestination
        }
    }
    
    /// An image from a `CGImageSource` along with metadata about the image
    private struct ImageSourceInfo {
        let source: CGImageSource
        let primaryImageIndex: Int
        let width: Int
        let height: Int
    }
    
    /// Opens an image file and extracts its source and metadata
    private func openImageSource(url: URL) async throws -> ImageSourceInfo {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw SpatialPhotoError.couldNotOpenImageSource
        }
        
        let primaryImageIndex = CGImageSourceGetPrimaryImageIndex(source)
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, primaryImageIndex, nil) as? [CFString: Any] else {
            throw SpatialPhotoError.couldNotCopyImageProperties
        }
        
        guard let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int else {
            throw SpatialPhotoError.unableToReadImageSize
        }
        
        return ImageSourceInfo(
            source: source,
            primaryImageIndex: primaryImageIndex,
            width: width,
            height: height
        )
    }
    
    /// Returns a 3x3 intrinsics matrix (with values expressed in pixels)
    /// for a simplified pinhole camera model with a spherical lens.
    private func calculateIntrinsics(width: Int, height: Int, horizontalFOV: Double) -> [Double] {
        let width = Double(width)
        let height = Double(height)
        let horizontalFOVInRadians = horizontalFOV / 180.0 * .pi
        let focalLengthX = (width * 0.5) / (tan(horizontalFOVInRadians * 0.5))
        
        // For a spherical pinhole camera, the focal length is the same in both X and Y
        let focalLengthY = focalLengthX
        
        // The principal point of the camera is assumed to be at the center of the image
        let principalPointX = 0.5 * width
        let principalPointY = 0.5 * height
        
        return [
            focalLengthX, 0, principalPointX,
            0, focalLengthY, principalPointY,
            0, 0, 1
        ]
    }
    
    /// Returns a properties dictionary that describes the spatial metadata for
    /// a left or right image in a stereo pair group.
    private func propertiesDictionary(
        isLeft: Bool,
        encodedDisparityAdjustment: Int,
        position: [Double],
        intrinsics: [Double]
    ) -> [CFString: Any] {
        return [
            kCGImagePropertyGroups: [
                kCGImagePropertyGroupIndex: 0,
                kCGImagePropertyGroupType: kCGImagePropertyGroupTypeStereoPair,
                (isLeft ? kCGImagePropertyGroupImageIsLeftImage : kCGImagePropertyGroupImageIsRightImage): true,
                kCGImagePropertyGroupImageDisparityAdjustment: encodedDisparityAdjustment
            ],
            kCGImagePropertyHEIFDictionary: [
                kIIOMetadata_CameraExtrinsicsKey: [
                    kIIOCameraExtrinsics_Position: position,
                    kIIOCameraExtrinsics_Rotation: identityRotation
                ],
                kIIOMetadata_CameraModelKey: [
                    kIIOCameraModel_Intrinsics: intrinsics,
                    kIIOCameraModel_ModelType: kIIOCameraModelType_SimplifiedPinhole
                ]
            ],
            kCGImagePropertyHasAlpha: false
        ]
    }
    
    /// Errors that can occur during spatial photo creation
    enum SpatialPhotoError: LocalizedError {
        case couldNotOpenImageSource
        case couldNotCopyImageProperties
        case unableToReadImageSize
        case imagesNotSameSize
        case unableToCreateImageDestination
        case unableToFinalizeImageDestination
        
        var errorDescription: String? {
            switch self {
            case .couldNotOpenImageSource:
                return "Could not open image as an image source."
            case .couldNotCopyImageProperties:
                return "Could not copy image properties."
            case .unableToReadImageSize:
                return "Unable to read image size."
            case .imagesNotSameSize:
                return "Left and right images must be the same size."
            case .unableToCreateImageDestination:
                return "Unable to create image destination."
            case .unableToFinalizeImageDestination:
                return "Unable to finalize image destination."
            }
        }
    }
}
