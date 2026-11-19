import Foundation

/// Dónde guarda el plugin sus fechas. Mismo patrón que `StorageProvider`.
protocol DueDateStorageProvider {
    func loadDueDates() async throws -> [TaskDueDate]
    func saveDueDates(_ dueDates: [TaskDueDate]) async throws
}

/// Guarda las fechas en su propio fichero, due-dates.json, junto a tasks.json.
final class JSONDueDateStorageProvider: DueDateStorageProvider {
    private let fileURL: URL

    init(filename: String = "due-dates.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(filename)
    }

    func loadDueDates() async throws -> [TaskDueDate] {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([TaskDueDate].self, from: data)
    }

    func saveDueDates(_ dueDates: [TaskDueDate]) async throws {
        let data = try JSONEncoder().encode(dueDates)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL)
    }
}
