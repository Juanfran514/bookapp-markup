import Foundation

/// Plugin con datos propios ligados a las tareas. El registro le avisa cuando se borra
/// una tarea, para que borre también sus datos (patrón observador).
protocol DataPlugin: FeaturePlugin {
    /// Antes de borrar la tarea: todavía se puede consultar.
    func willDeleteTask(_ task: Task)
    /// Después de borrarla: ya solo queda su id.
    func didDeleteTask(id: UUID)
}
