//
//  DreamService.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//

// DreamStorageService.swift
import Foundation

actor DreamStorageService {
    private let fileManager = FileManager.default
    private var documentsDirectory: URL {
        try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    private var dreamsFileURL: URL {
        documentsDirectory.appendingPathComponent("dreams.json")
    }
    
    func saveDream(_ dream: DreamEntry) async throws {
        var dreams = try await loadDreams()
        dreams.append(dream)
        try await saveDreams(dreams)
    }
    
    func loadDreams() async throws -> [DreamEntry] {
        guard fileManager.fileExists(atPath: dreamsFileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: dreamsFileURL)
        return try JSONDecoder().decode([DreamEntry].self, from: data)
    }
    
    private func saveDreams(_ dreams: [DreamEntry]) async throws {
        let data = try JSONEncoder().encode(dreams)
        try data.write(to: dreamsFileURL)
    }
    
    func deleteDream(with id: UUID) async throws {
        var dreams = try await loadDreams()
        dreams.removeAll { $0.id == id }
        try await saveDreams(dreams)
    }
}
