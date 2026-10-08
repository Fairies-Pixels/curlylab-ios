import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            SignInScreen(
                onSignIn: {
                    path.append(Route.home)
                },
                onGoToSignUp: {
                    path.append(Route.signUp)
                }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .signIn:
                    SignInScreen(
                        onSignIn: { path.append(Route.home) },
                        onGoToSignUp: { path.append(Route.signUp) }
                    )
                case .signUp:
                    SignUpScreen(
                        onSignUp: { path.append(Route.home) },
                        onGoToSignIn: { path.removeLast() }
                    )
                case .home:
                    HomeScreen(
                        onOpenComposition: { /* TODO */ },
                        onOpenGuide: { /* TODO */ },
                        onOpenDictionary: { /* TODO */ },
                        onOpenHairTyping: { /* TODO */ },
                        onOpenProducts: { /* TODO */ }
                    )
                }
            }
        }
    }
}
