import Foundation

/// Registro de plugins. El núcleo habla con el registro, nunca con un plugin concreto.
final class PluginRegistry {
    /// Un único registro para toda la app (patrón Singleton).
    static let shared = PluginRegistry()

    /// Los plugins registrados, en el orden en que se registraron.
    private(set) var plugins: [FeaturePlugin] = []

    private init() {}

    /// Añade un plugin. Registrar dos veces el mismo no hace nada.
    func register(_ plugin: FeaturePlugin) {
        guard !plugins.contains(where: { $0 === plugin }) else { return }
        plugins.append(plugin)
        print("Plugin registrado: \(plugin.name)")
    }

    /// Los plugins que quieren saber cuándo se borra una tarea.
    private var dataPlugins: [DataPlugin] {
        plugins.compactMap { $0 as? DataPlugin }
    }

    /// Avisa a los plugins de datos de que una tarea se va a borrar.
    func notifyTaskWillBeDeleted(_ task: Task) {
        for plugin in dataPlugins {
            plugin.willDeleteTask(task)
        }
    }

    /// Avisa a los plugins de datos de que una tarea se ha borrado.
    func notifyTaskDidDelete(id: UUID) {
        for plugin in dataPlugins {
            plugin.didDeleteTask(id: id)
        }
    }
}
