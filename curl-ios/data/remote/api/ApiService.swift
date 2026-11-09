import Foundation

final class ApiService {
    static let shared = ApiService()

    private let baseURL = "https://curlylab.ru:8080"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        let request = try await buildRequest(
            path,
            method: "GET",
            queryItems: queryItems
        )
        return try await execute(request)
    }

    func put<T: Encodable>(_ path: String, body: T, token: String?) async throws {
        var request = try await buildRequest(path, method: "PUT", token: token)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.unknown
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ApiError.http(
                code: httpResponse.statusCode,
                message: String(data: data, encoding: .utf8) ?? "Ошибка сохранения"
            )
        }
    }

    func post<T: Decodable, U: Encodable>(_ path: String, body: U?) async throws -> T {
        var request = try await buildRequest(path, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        return try await execute(request)
    }

    func putReturning<T: Decodable, U: Encodable>(_ path: String, body: U?) async throws -> T {
        var request = try await buildRequest(path, method: "PUT")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        return try await execute(request)
    }

    func delete<T: Decodable>(_ path: String) async throws -> T {
        let request = try await buildRequest(path, method: "DELETE")
        return try await execute(request)
    }

    private func buildRequest(
        _ path: String,
        method: String,
        queryItems: [URLQueryItem]? = nil,
        token: String? = nil
    ) async throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw ApiError.invalidURL
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let storedToken = await AuthManager.shared.getAccessToken()
        let effectiveToken = token ?? storedToken
        if let effectiveToken {
            request.setValue("Bearer \(effectiveToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.unknown
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                throw ApiError.http(
                    code: httpResponse.statusCode,
                    message: String(data: data, encoding: .utf8)
                )
            }

            if data.isEmpty {
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                throw ApiError.decoding(
                    NSError(
                        domain: "ApiService",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Пустой ответ, ожидался \(T.self)"]
                    )
                )
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw ApiError.decoding(error)
            }
        } catch let error as ApiError {
            throw error
        } catch {
            throw ApiError.network(error)
        }
    }

    private func executeVoid(_ request: URLRequest) async throws {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw ApiError.unknown }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw ApiError.http(code: httpResponse.statusCode, message: String(data: data, encoding: .utf8))
            }
        } catch let error as ApiError {
            throw error
        } catch {
            throw ApiError.network(error)
        }
    }
}

struct EmptyResponse: Decodable {}
