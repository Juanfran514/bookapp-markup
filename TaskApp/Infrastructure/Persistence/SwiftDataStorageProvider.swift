// SwiftData solo existe en los sistemas de Apple. En Linux y Windows este fichero
// queda vacío al compilar y la app guarda siempre en JSON.
#if canImport(SwiftData)
import Foundation
import SwiftData

/// Cómo guarda SwiftData una tarea. `Task` sigue siendo un struct que usan las vistas
/// y el ViewModel; esta clase solo la conoce el almacenamiento.
@Model
final class TaskEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var priority: Priority?
    /// SwiftData no guarda el orden de la lista: lo guardamos nosotros.
    var position: Int

    init(task: Task, position: Int) {
        id = task.id
        title = task.title
        isCompleted = task.isCompleted
        priority = task.priority
        self.position = position
    }

    /// Copia en la entidad lo que se ha cambiado en la tarea.
    func update(from task: Task, position: Int) {
        title = task.title
        isCompleted = task.isCompleted
        priority = task.priority
        self.position = position
    }

    /// La tarea que usan las vistas.
    var task: Task {
        Task(id: id, title: title, isCompleted: isCompleted, priority: priority)
    }
}

/// Guarda las tareas en una base de datos de SwiftData (un fichero TaskApp.store).
final class SwiftDataStorageProvider: StorageProvider {
    /// Un solo almacén para toda la app, aunque la lista se cree varias veces.
    static let shared = SwiftDataStorageProvider()

    private let container: ModelContainer

    private init() {
        do {
            container = try ModelContainer(
                for: TaskEntity.self,
                configurations: ModelConfiguration("TaskApp"))
        } catch {
            fatalError("No se ha podido abrir el almacén de SwiftData: \(error)")
        }
    }

    private var context: ModelContext { container.mainContext }

    func loadTasks() async throws -> [Task] {
        let byPosition = FetchDescriptor<TaskEntity>(sortBy: [SortDescriptor(\.position)])
        return try context.fetch(byPosition).map(\.task)
    }

    func saveTasks(tasks: [Task]) async throws {
        // Las entidades guardadas, por id, para saber cuáles cambian y cuáles sobran.
        var stored: [UUID: TaskEntity] = [:]
        for entity in try context.fetch(FetchDescriptor<TaskEntity>()) {
            stored[entity.id] = entity
        }

        for (position, task) in tasks.enumerated() {
            if let entity = stored.removeValue(forKey: task.id) {
                entity.update(from: task, position: position)
            } else {
                context.insert(TaskEntity(task: task, position: position))
            }
        }
        // Las que quedan ya no están en la lista: se han borrado.
        for entity in stored.values {
            context.delete(entity)
        }
        try context.save()
    }
}
#endif
