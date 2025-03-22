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
    
    init(title: String = "", content: String = "", date: Date = Date()) {
        self.title = title
        self.content = content
        self.date = date
    }
}
