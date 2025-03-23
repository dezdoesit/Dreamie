//
//  DreamModel.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//

import Foundation

struct DreamEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var date: Date
    var spatialPhotoData: Data?
    var spatialPhotoURL: String?
    
    init(title: String = "", content: String = "", date: Date = Date(), spatialPhotoData: Data? = nil, spatialPhotoURL: String? = nil) {
        self.title = title
        self.content = content
        self.date = date
        self.spatialPhotoData = spatialPhotoData
        self.spatialPhotoURL = spatialPhotoURL
    }
}
