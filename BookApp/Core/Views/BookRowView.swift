import Foundation
import SwiftUI

/// Lomo de un libro en la estantería. Se adapta exactamente al ancho dinámico `cellWidth` de su celda.
struct BookRowView: View {
    let book: Book
    let cellWidth: Double
    let dueDate: Date?
    let showDueDates: Bool
    let showPriorities: Bool
    /// En modo edición es `nil`: no se muestra el botón de marcar para poder arrastrar el libro.
    let toggleRead: (() -> Void)?

    var body: some View {
        let innerWidth = max(20.0, cellWidth - 6.0)
        ZStack {
            Rectangle()
                .fill(book.coverColor.color)
                .shelfFrame(width: cellWidth, height: 150)

            // Título centrado exactamente en mitad del lomo (horizontal y verticalmente)
            Text(book.title)
                .font(.caption)
                .foregroundColor(.white)
                .strikethrough(book.isRead)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .shelfFrame(width: 96, height: innerWidth)
                .rotationEffect(.degrees(-90))
                .shelfFrame(width: innerWidth, height: 96)

            // Controles arriba (marcar leído / indicador de edición) y abajo (fecha / prioridad)
            VStack(spacing: 2) {
                if let toggleRead {
                    Button(action: toggleRead) {
                        Image(systemName: book.isRead ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 6)
                } else {
                    Text("⇄")
                        .bookCaption(color: .white.opacity(0.9))
                        .padding(.top, 6)
                }

                Spacer(minLength: 0)

                if showDueDates, let dueDate {
                    Text(dueDate.formatted(date: .numeric, time: .omitted))
                        .bookCaption(color: .white.opacity(0.85))
                        .lineLimit(1)
                        .shelfFrame(width: innerWidth, height: 16)
                }
#if Prioridades
                if showPriorities, let priority = book.priority {
                    Text(priority.rawValue)
                        .bookCaption(color: .white.opacity(0.9))
                        .lineLimit(1)
                        .shelfFrame(width: innerWidth, height: 16)
                }
#endif
            }
            .padding(.bottom, 4)
            .shelfFrame(width: cellWidth, height: 150)
        }
        .shelfFrame(width: cellWidth, height: 150)
        .clipped()
    }
}
