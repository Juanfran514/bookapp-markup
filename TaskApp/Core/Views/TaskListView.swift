import SwiftUI

struct TaskListView: View {
    @State private var viewModel: TaskListViewModel
    /// La configuración la crea la app y llega por el entorno: es la misma que edita Ajustes.
    @Environment(AppConfig.self) private var config
    /// El plugin de fechas también llega por el entorno. La lista le pide la fecha de cada
    /// tarea y se la pasa a la fila (el valor) y al detalle (un Binding).
    @Environment(DueDatePlugin.self) private var dueDates

    /// Quien crea la lista decide dónde se guardan las tareas.
    init(storageProvider: StorageProvider = JSONStorageProvider()) {
        _viewModel = State(wrappedValue: TaskListViewModel(storageProvider: storageProvider))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.tasks) { task in
                    taskRow(task: task)
                }
            }
            .toolbar {
                Button("Añadir tarea") {
                    viewModel.addTask()
                }
            }
            .navigationTitle("Tareas")
        }
    }

    /// Una fila: enlace al detalle de la tarea, con menú contextual para borrarla.
    private func taskRow(task: Task) -> some View {
        NavigationLink(destination: TaskDetailView(task: binding(for: task), dueDate: dueDateBinding(for: task))) {
            TaskRowView(
                task: task,
                dueDate: dueDates.dueDate(for: task.id),
                showDueDates: config.showDueDates,
                showPriorities: config.showPriorities,
                toggleCompletion: { viewModel.toggleCompletion(id: task.id) }
            )
            .contextMenu {
                Button("Eliminar tarea") {
                    viewModel.removeTask(id: task.id)
                }
            }
        }
    }

    /// Un enlace (Binding) para que el detalle edite la tarea. No toca los datos:
    /// leer y escribir se traducen a métodos del ViewModel.
    private func binding(for task: Task) -> Binding<Task> {
        Binding(
            get: { viewModel.task(id: task.id) ?? task },
            set: { viewModel.updateTask($0) }
        )
    }

    /// Lo mismo para la fecha: leer y escribir se traducen a métodos del plugin.
    private func dueDateBinding(for task: Task) -> Binding<Date?> {
        // El Binding se usa más tarde (al pulsar): guarda el plugin, no la propiedad del entorno.
        let plugin = dueDates
        return Binding(
            get: { plugin.dueDate(for: task.id) },
            set: { plugin.setDueDate($0, for: task.id) }
        )
    }
}
