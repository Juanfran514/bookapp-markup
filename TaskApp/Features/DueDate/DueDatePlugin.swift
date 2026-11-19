import Foundation
import Observation

/// Plugin de fechas de vencimiento. Guarda la fecha de cada tarea en su propio fichero
/// y, como plugin de datos, la borra cuando se borra la tarea.
@Observable
final class DueDatePlugin: DataPlugin {
    let name = "Fechas de vencimiento"

    /// Las fechas guardadas. Cada cambio se guarda.
    private(set) var dueDates: [TaskDueDate] = [] {
        didSet { save() }
    }

    @ObservationIgnored private let storageProvider: DueDateStorageProvider
    @ObservationIgnored private var loaded = false

    init(storageProvider: DueDateStorageProvider = JSONDueDateStorageProvider()) {
        self.storageProvider = storageProvider
        _Concurrency.Task { await loadDueDates() }
    }

    /// Carga las fechas guardadas, solo la primera vez. Si no hay fichero, no hay fechas.
    func loadDueDates() async {
        guard !loaded else { return }
        loaded = true
        do {
            dueDates = try await storageProvider.loadDueDates()
        } catch {
            print("No se han cargado fechas: \(error)")
        }
    }

    /// La fecha de una tarea, si tiene.
    func dueDate(for taskID: UUID) -> Date? {
        dueDates.first { $0.taskID == taskID }?.date
    }

    /// Pone o quita (nil) la fecha de una tarea.
    func setDueDate(_ date: Date?, for taskID: UUID) {
        var updated = dueDates.filter { $0.taskID != taskID }
        if let date {
            updated.append(TaskDueDate(taskID: taskID, date: date))
        }
        dueDates = updated  // un solo cambio: se guarda una vez
    }

    // MARK: - DataPlugin: el registro nos avisa al borrar una tarea

    func willDeleteTask(_ task: Task) {
        guard dueDate(for: task.id) != nil else { return }
        setDueDate(nil, for: task.id)
        print("\(name): borrada la fecha de «\(task.title)»")
    }

    func didDeleteTask(id: UUID) {
        print("\(name): la tarea \(id) ya no existe")
    }

    private func save() {
        let dueDates = dueDates
        _Concurrency.Task {
            do {
                try await storageProvider.saveDueDates(dueDates)
            } catch {
                print("No se han guardado las fechas: \(error)")
            }
        }
    }
}
