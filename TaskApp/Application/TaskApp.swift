import SwiftUI

@main
struct TaskApp: App {
    /// Una sola configuración para toda la app: la comparten Tareas y Ajustes.
    @State private var config = AppConfig()
    @State private var selection: String? = "tareas"
    @State private var dueDates: DueDatePlugin

    /// Los plugins se crean y se registran una sola vez, al arrancar la app.
    init() {
        let dueDates = DueDatePlugin()
        PluginRegistry.shared.register(dueDates)
        _dueDates = State(wrappedValue: dueDates)
    }

    var body: some Scene {
        WindowGroup {
#if os(iOS)
            TabView {
                TaskListView(storageProvider: config.storageType.makeProvider())
                    // Las pestañas conservan su estado: al cambiar de almacenamiento se rehace la lista.
                    .id(config.storageType)
                    .tabItem { Label("Tareas", systemImage: "checklist") }
                SettingsView()
                    .tabItem { Label("Ajustes", systemImage: "gearshape") }
            }
            .environment(config)
            .environment(dueDates)
#else
            NavigationSplitView {
                List(selection: $selection) {
                    NavigationLink(value: "tareas") {
                        Label("Tareas", systemImage: "checklist")
                    }
                    NavigationLink(value: "ajustes") {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                }
            } detail: {
                switch selection {
                case "tareas":
                    // La lista se crea al elegir Tareas, con el almacenamiento elegido en Ajustes.
                    TaskListView(storageProvider: config.storageType.makeProvider())
                case "ajustes":
                    SettingsView()
                default:
                    Text("Elige una opción")
                }
            }
            .environment(config)
            .environment(dueDates)
#endif
        }
    }
}
