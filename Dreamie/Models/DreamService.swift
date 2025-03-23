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
        if let index = dreams.firstIndex(where: { $0.id == dream.id }) {
            dreams[index] = dream // Update existing dream
        } else {
            dreams.append(dream) // Add new dream
        }
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
    
    func updateDream(id: UUID, spatialPhotoData: Data?, spatialPhotoURL: String?) async throws {
        var dreams = try await loadDreams()
        if let index = dreams.firstIndex(where: { $0.id == id }) {
            dreams[index].spatialPhotoData = spatialPhotoData
            dreams[index].spatialPhotoURL = spatialPhotoURL
            try await saveDreams(dreams)
        }
    }
    
    func getDream(with id: UUID) async throws -> DreamEntry? {
        let dreams = try await loadDreams()
        return dreams.first(where: { $0.id == id })
    }
}
