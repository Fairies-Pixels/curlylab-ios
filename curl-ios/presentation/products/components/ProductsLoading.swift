import SwiftUI

struct ProductsLoading: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color(hex: "728C6A"))
            Text("Загрузка средств...")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "4A5B48").opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}
