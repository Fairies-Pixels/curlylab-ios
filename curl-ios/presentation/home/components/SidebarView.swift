import SwiftUI

struct SidebarView: View {
    let onOpenComposition: () -> Void
    let onOpenGuide: () -> Void
    let onOpenDictionary: () -> Void
    let onOpenHairTyping: () -> Void
    let onOpenProducts: () -> Void
    
    @State private var hairPorosity = "Средне-пористые"
    @State private var hairThickness = "Тонкие"
    @State private var hairColoring = "Неокрашенные"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            profileHeader
            
            Divider()
                .overlay(Color.panelBackground)
                .padding(.vertical, 10)
            
            hairTypeCard(
                title: "Пористость",
                value: hairPorosity,
                color: .cardOrange,
                options: [
                    "Низко-пористые",
                    "Средне-пористые",
                    "Высоко-пористые"
                ]
            ) { hairPorosity = $0 }
            
            hairTypeCard(
                title: "Толщина",
                value: hairThickness,
                color: .cardBlue,
                options: [
                    "Тонкие",
                    "Средние",
                    "Толстые"
                ]
            ) { hairThickness = $0 }
            
            hairTypeCard(
                title: "Окрашенность",
                value: hairColoring,
                color: .cardBeige,
                textColor: .cardGreen,
                options: [
                    "Неокрашенные",
                    "Окрашенные",
                    "Осветлённые"
                ]
            ) { hairColoring = $0 }
            
            Divider()
                .overlay(Color.panelBackground)
                .padding(.vertical, 10)
            
            Button {
                // Здесь подключается существующая логика выхода.
            } label: {
                Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.bodySerif)
                    .foregroundStyle(Color.panelBackground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .padding(16)
        .background(Color.darkGreen)
        .ignoresSafeArea(edges: .bottom)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 2, y: 0)
    }
    
    private func hairTypeCard(
        title: String,
        value: String,
        color: Color,
        textColor: Color = .panelBackground,
        options: [String],
        onSelect: @escaping (String) -> Void
    ) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.captionSerif)
                .tracking(0.5)
                .foregroundStyle(Color.panelBackground)
                .fixedSize()
                .rotationEffect(.degrees(-90))
                .frame(width: 22, height: 100)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        onSelect(option)
                    }
                }
            } label: {
                Text(value)
                    .font(.bodySerif)
                    .tracking(0.3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.bottom, 10)
    }
    
    private var profileHeader: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.darkGreen)
                    .frame(width: 130, height: 130)
                    .background(Color.panelBackground)
                    .clipShape(Circle())
                
                Button {
                    // Здесь можно открыть выбор фотографии.
                } label: {
                    Image(systemName: "plus")
                        .font(.bodySerif)
                        .foregroundStyle(Color.panelBackground)
                        .frame(width: 34, height: 34)
                        .background(Color.cardGreen)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            
            Text("Имя")
                .font(.titleSerif)
                .foregroundStyle(Color.panelBackground)
            
            Text(verbatim: "EMAIL@MAIL.COM")
                .font(.captionSerif)
                .tracking(1)
                .foregroundStyle(Color.panelBackground)
            
            Button {
                // Здесь подключается экран редактирования профиля.
            } label: {
                Text("Редактировать")
                    .font(.bodySerif)
                    .tracking(0.6)
                    .foregroundStyle(Color.panelBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.cardGreen)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
    }
}
