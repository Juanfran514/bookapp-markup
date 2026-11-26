import Foundation
import SwiftUI

/// Lomo de un libro en la estantería. Mantiene su proporción adaptándose a `cellWidth` y `cellHeight`.
struct BookRowView: View {
    let book: Book
    let cellWidth: Double
    let cellHeight: Double
    let dueDate: Date?
    let showDueDates: Bool
    let showPriorities: Bool
    /// En modo edición es `nil`: no se muestra el botón de marcar para poder arrastrar el libro.
    let toggleRead: (() -> Void)?

    var body: some View {
        let innerWidth = max(20.0, cellWidth - 6.0)
        let titleLength = max(50.0, cellHeight - 54.0)
        ZStack {
            // Fondo del libro con el título centrado en overlay (no altera el tamaño de la celda
            // ni comprime el texto tras rotarlo)
            Rectangle()
                .fill(book.coverColor.color)
                .shelfFrame(width: cellWidth, height: cellHeight)
                .overlay(
                    Text(book.title)
                        .font(.caption)
                        .foregroundColor(.white)
                        .strikethrough(book.isRead)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .shelfFrame(width: titleLength, height: innerWidth)
                        .rotationEffect(.degrees(-90))
                )

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
            .shelfFrame(width: cellWidth, height: cellHeight)
        }
        .shelfFrame(width: cellWidth, height: cellHeight)
        .clipped()
    }
}
