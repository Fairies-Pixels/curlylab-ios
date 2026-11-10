import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let apiService = ApiService.shared
    private let authManager = AuthManager.shared
    private let userDefaultsService = UserDefaultsService.shared
    private let userRepository: UserRepository = UserRepositoryImpl()
    private let hairTypeRepository: HairTypesRepository = HairTypesRepositoryImpl()

    func register(email: String, password: String, username: String) async throws -> AuthResponse {
        do {
            let path = "/auth/register"
            let body = RegisterRequest(email: email, password: password, username: username)

            let authResponse: AuthResponse = try await apiService.post(
                path,
                body: body
            )

            guard let userId = JwtDecoder.decodeUserId(authResponse.access) else {
                throw AuthError.invalidToken
            }

            await authManager.saveAuthData(
                isLoggedIn: true,
                accessToken: authResponse.access,
                refreshToken: authResponse.refresh,
                userId: userId,
                username: username,
                email: email
            )
            UserDefaultsService.shared.name  = username
            UserDefaultsService.shared.email = email
            return authResponse
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.network(error.localizedDescription)
        }
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        do {
            let path = "/auth/login"
            let body = LoginRequest(email: email, password: password)

            let authResponse: AuthResponse = try await apiService.post(
                path,
                body: body
            )

            guard let userId = JwtDecoder.decodeUserId(authResponse.access) else {
                throw AuthError.invalidToken
            }
            
            let user = try await userRepository.getUser(id: userId)
            let userHairType = try await hairTypeRepository.getHairType(userId: userId)

            await authManager.saveAuthData(
                isLoggedIn: true,
                accessToken: authResponse.access,
                refreshToken: authResponse.refresh,
                userId: userId,
                username: user.username,
                email: email
            )
            UserDefaultsService.shared.name = user.username
            UserDefaultsService.shared.email = email
            UserDefaultsService.shared.hairColoring = userDefaultsService.coloredFromDbCode(dbCode: userHairType.isColored)
            UserDefaultsService.shared.hairPorosity = userDefaultsService.porosityFromDbCode(dbCode: userHairType.porosity)
            UserDefaultsService.shared.hairThickness = userDefaultsService.thicknessFromDbCode(dbCode: userHairType.thickness)
            
            return authResponse
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.network(error.localizedDescription)
        }
    }

    func isUserLoggedIn() async -> Bool {
        await authManager.isLoggedIn
    }

    func logout() async {
        do {
            if let refreshToken = await authManager.getRefreshToken() {
                let path = "/auth/logout"
                let body = LogoutRequest(refreshToken: refreshToken)
                let resp: AuthResponse = try await apiService.post(
                    path,
                    body: body
                )
            }
        } catch {
            print("Logout error: \(error)")
        }
        await authManager.clearAuthData()
        userDefaultsService.reset()
    }

    func getAccessToken() async -> String? {
        await authManager.getAccessToken()
    }

    func getUserId() async -> String? {
        await authManager.getUserId()
    }
}
