import SwiftUI

struct TypingResultView: View {
    let resultTitle: String
    let onSave: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Ваш результат")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(hex: "4A5B48"))

            Text(resultTitle.capitalized)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color(hex: "728C6A"))

            Spacer()

            Button("Сохранить результат", action: onSave)
                .buttonStyle(PrimaryButtonStyle())

            Button("Не сохранять", action: onSkip)
                .buttonStyle(SecondaryButtonStyle())
        }
        .padding(24)
    }
}
