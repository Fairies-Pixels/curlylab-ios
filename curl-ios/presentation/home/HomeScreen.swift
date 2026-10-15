import SwiftUI

struct HomeScreen: View {
    let onOpenComposition: () -> Void
    let onOpenGuide: () -> Void
    let onOpenDictionary: () -> Void
    let onOpenHairTyping: () -> Void
    let onOpenProducts: () -> Void
    
    @State private var isSidebarOpen = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            mainContent
                .disabled(isSidebarOpen)
            
            if isSidebarOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isSidebarOpen = false
                        }
                    }
                    .offset(x: isSidebarOpen ? 280 : 0)
                    .transition(.opacity)
            }
            
            SidebarView(
                onOpenComposition: {
                    isSidebarOpen = false
                    onOpenComposition()
                },
                onOpenGuide: {
                    isSidebarOpen = false
                    onOpenGuide()
                },
                onOpenDictionary: {
                    isSidebarOpen = false
                    onOpenDictionary()
                },
                onOpenHairTyping: {
                    isSidebarOpen = false
                    onOpenHairTyping()
                },
                onOpenProducts: {
                    isSidebarOpen = false
                    onOpenProducts()
                }
            )
            .frame(width: 280)
            .offset(x: isSidebarOpen ? 0 : -280)
            .animation(.easeInOut(duration: 0.25), value: isSidebarOpen)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack() {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isSidebarOpen = true
                        }
                    } label: {
                        avatarView
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("Привет,")
                            .font(.titleSerif)
                            .foregroundStyle(Color("CurlyDarkGreen"))
                        Text("Имя!")
                            .font(.titleSerif)
                            .foregroundStyle(Color("CurlyDarkGreen"))
                    }
                    
                }
                
                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(spacing: 16) {
                            FeatureCard(
                                color: Color("CurlyGreen"),
                                title: "Проверка составов",
                                height: 280,
                                action: onOpenComposition
                            )
                            FeatureCard(
                                color: Color("CurlyBlue"),
                                title: "Гайд",
                                height: 132,
                                action: onOpenGuide
                            )
                        }
                        
                        VStack(spacing: 16) {
                            FeatureCard(
                                color: Color("CurlyOrange"),
                                title: "Словарь",
                                height: 132,
                                action: onOpenDictionary
                            )
                            FeatureCard(
                                color: Color.lightPink,
                                title: "Типизация волос",
                                height: 280,
                                action: onOpenHairTyping
                            )
                        }
                    }
                    
                    FeatureCard(
                        color: Color("CurlyLavander"),
                        title: "База средств",
                        height: 132,
                        action: onOpenProducts
                    )
                }
            }
            .padding(24)
        }
        .background(Color("CurlySurface"))
        .animation(.easeInOut(duration: 0.25), value: isSidebarOpen)
    }
    
    private var avatarView: some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color("CurlySurface"))
            .frame(width: 130, height: 130)
            .background(Color("CurlyDarkGreen"))
            .clipShape(Circle())
        
    }
}
