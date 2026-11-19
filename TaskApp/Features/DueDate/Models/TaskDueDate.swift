import Foundation

/// La fecha de vencimiento de una tarea. Es un dato del plugin, no de `Task`:
/// se une a la tarea por su id.
struct TaskDueDate: Codable {
    let taskID: UUID
    var date: Date
}
