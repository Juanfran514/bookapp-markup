import SwiftUI

/// Detalle de una tarea. Recibe un enlace (@Binding) a la tarea de la lista:
/// lo que se edita aquí cambia la tarea del ViewModel, sin copias.
/// La fecha la edita la vista del plugin de fechas, que el detalle conoce directamente.
struct TaskDetailView: View {
    @Binding var task: Task
    @Binding var dueDate: Date?

    var body: some View {
        Form {
            TextField("Título de la tarea", text: $task.title)
            Toggle("Completada", isOn: $task.isCompleted)
            DueDateDetailView(dueDate: $dueDate)
        }
        .navigationTitle(task.title)
    }
}
