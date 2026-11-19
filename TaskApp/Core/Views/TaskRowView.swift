import SwiftUI

/// Fila de una tarea. No conoce el ViewModel: recibe los flags y la acción.
/// Sí conoce la vista del plugin de fechas (acoplamiento que la sesión 8 quita).
struct TaskRowView: View {
    let task: Task
    let dueDate: Date?
    let showDueDates: Bool
    let showPriorities: Bool
    let toggleCompletion: () -> Void

    var body: some View {
        HStack {
            Button(action: toggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.taskAccent)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                if showDueDates {
                    DueDateRowView(date: dueDate)
                }
#if Prioridades
                if showPriorities, let priority = task.priority {
                    Text("Prioridad: \(priority.rawValue)")
                        .taskCaption(color: priority.color)
                }
#endif
            }
        }
    }
}
