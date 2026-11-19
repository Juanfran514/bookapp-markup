import Foundation

/// Codable: la tarea se puede guardar y leer en JSON.
/// La fecha de vencimiento ya no está aquí: es un dato del plugin DueDate.
struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: Priority?
}
