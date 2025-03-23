//
//  PickerView.swift
//  Dreamie
//
//  Created by Christopher Woods on 3/22/25.
//


//
//  PickerView.swift
//  2
//
//  Created by Christopher Woods on 3/22/25.
//


import SwiftUI
import PhotosUI
import QuickLook

struct PickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageURL: URL?
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .spatialMedia) {
                Text("Choose a spatial photo or video")
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }
            
        }
        
        
        // After selecting the spatial photo in your PhotosPicker
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    // Save the data to a temporary file
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension("heic")
                    
                    try? data.write(to: tempURL)
                    selectedImageURL = tempURL
                    
                    // Use the static open method instead of trying to initialize PreviewApplication
                    try? await PreviewApplication.open(urls: [tempURL])
                }
            }
        }
    }
}
