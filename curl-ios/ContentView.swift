import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            SignInScreen(
                onSignIn: { path.append(Route.home) },
                onGoToSignUp: { path.append(Route.signUp) }
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
                        router: HomeScreenRouterAdapter(
                            onComposition: { path.append(Route.composition) },
                            onGuide:       { path.append(Route.guide) },
                            onDictionary:  { path.append(Route.dictionary) },
                            onHairTyping:  { path.append(Route.hairTyping) },
                            onProducts:    { path.append(Route.products) }
                        )
                    )

                case .composition:
                    GuideScreen()// TODO(поменять)

                case .guide:
                    GuideScreen()

                case .dictionary:
                    DictionaryScreen()

                case .hairTyping:
                    GuideScreen()// TODO(поменять)

                case .products:
                    ProductsScreen(viewModel: ProductsViewModelFactory.make())
                }
            }
        }
    }
}
