import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Sidebar / main state

    @Published var isSidebarOpen: Bool = false
    @Published var isLoading: Bool = false
    @Published private(set) var userName: String = ""

    @Published private(set) var email: String = ""
    @Published private(set) var hairPorosity: String = ""
    @Published private(set) var hairThickness: String = ""
    @Published private(set) var hairColoring: String = ""

    private let profileService: UserDefaultsService
    private let router: HomeRouter
    private var cancellables = Set<AnyCancellable>()

    init(
        profileService: UserDefaultsService = .shared,
        router: HomeRouter
    ) {
        self.profileService = profileService
        self.router = router
        refreshFromProfile()
        bindProfile()
    }

    private func refreshFromProfile() {
        userName      = Self.displayName(from: profileService.name)
        email         = profileService.email
        hairPorosity  = profileService.hairPorosity
        hairThickness = profileService.hairThickness
        hairColoring  = profileService.hairColoring
    }

    private func bindProfile() {
        profileService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                DispatchQueue.main.async { self.refreshFromProfile() }
            }
            .store(in: &cancellables)
    }

    func setHairPorosity(_ value: String)  { profileService.hairPorosity = value }
    func setHairThickness(_ value: String) { profileService.hairThickness = value }
    func setHairColoring(_ value: String)  { profileService.hairColoring = value }

    func onAppear() {
        loadProfile()
    }

    private func loadProfile() {
        isLoading = true
        defer { isLoading = false }
        refreshFromProfile()
    }

    private static func displayName(from name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Имя" : trimmed
    }

    func openSidebar() {
        withAnimation(.easeInOut(duration: 0.25)) { isSidebarOpen = true }
    }

    func closeSidebar() {
        withAnimation(.easeInOut(duration: 0.25)) { isSidebarOpen = false }
    }

    func toggleSidebar() {
        isSidebarOpen ? closeSidebar() : openSidebar()
    }

    func didTapPickPhoto() {
        // логику выбора фото
    }

    func didTapEditProfile() {
        // открыть экран редактирования профиля
    }

    func didTapSignOut() {
        // логика выхода
    }

    func didTapComposition() { router.openComposition() }
    func didTapGuide()       { router.openGuide() }
    func didTapDictionary()  { router.openDictionary() }
    func didTapHairTyping()  { router.openHairTyping() }
    func didTapProducts()    { router.openProducts() }

    func didSelectSidebarComposition() { closeSidebar(); router.openComposition() }
    func didSelectSidebarGuide()       { closeSidebar(); router.openGuide() }
    func didSelectSidebarDictionary()  { closeSidebar(); router.openDictionary() }
    func didSelectSidebarHairTyping()  { closeSidebar(); router.openHairTyping() }
    func didSelectSidebarProducts()    { closeSidebar(); router.openProducts() }
}
