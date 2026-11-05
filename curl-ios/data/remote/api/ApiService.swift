import Foundation

final class ApiService {
    static let shared = ApiService()

    private let baseURL = "https://curlylab.ru:8080"
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func get<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem]? = nil,
        token: String? = nil
    ) async throws -> T {
        let request = try await buildRequest(
            path,
            method: "GET",
            queryItems: queryItems,
            token: token
        )
        return try await perform(request)
    }

    func post<T: Decodable, U: Encodable>(
        _ path: String,
        body: U?,
        token: String? = nil
    ) async throws -> T {
        var request = try await buildRequest(path, method: "POST", token: token)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body {
            request.httpBody = try encoder.encode(body)
        }
        return try await perform(request)
    }

    func put<T: Decodable, U: Encodable>(
        _ path: String,
        body: U?,
        token: String? = nil
    ) async throws -> T {
        var request = try await buildRequest(path, method: "PUT", token: token)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body {
            request.httpBody = try encoder.encode(body)
        }
        return try await perform(request)
    }

    func delete<T: Decodable>(
        _ path: String,
        token: String? = nil
    ) async throws -> T {
        let request = try await buildRequest(path, method: "DELETE", token: token)
        return try await perform(request)
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

        let effectiveToken = token ?? (await AuthManager.shared.getAccessToken())
        if let effectiveToken {
            request.setValue("Bearer \(effectiveToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
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
                return try decoder.decode(T.self, from: data)
            } catch {
                throw ApiError.decoding(error)
            }
        } catch let error as ApiError {
            throw error
        } catch {
            throw ApiError.network(error)
        }
    }
}

struct EmptyResponse: Decodable {}
