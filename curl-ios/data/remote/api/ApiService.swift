import Foundation

final class ApiService {
    static let shared = ApiService()

    private let baseURL = "https://dummyjson.com"
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }

    func get<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        guard var components = URLComponents(string: baseURL + path) else {
            throw ApiError.invalidURL
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return try await perform(request)
    }

    func post<T: Decodable, U: Encodable>(
        _ path: String,
        body: U
    ) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw ApiError.decoding(error)
        }

        return try await perform(request)
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        logRequest(request)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.unknown
            }

            logResponse(httpResponse, data: data)

            guard (200..<300).contains(httpResponse.statusCode) else {
                throw ApiError.http(
                    code: httpResponse.statusCode,
                    message: String(data: data, encoding: .utf8)
                )
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                print("[DECODE] Не удалось декодировать \(T.self): \(error)")
                throw ApiError.decoding(error)
            }
        } catch let error as ApiError {
            logError(error)
            throw error
        } catch {
            print("[NETWORK] \(error.localizedDescription)")
            throw ApiError.network(error)
        }
    }

    private func logRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "?"
        let url = request.url?.absoluteString ?? "?"

        print("")
        print("[\(method)] \(url)")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("   Headers:")
            for (key, value) in headers {
                print("     \(key): \(value)")
            }
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("   Body: \(bodyString)")
        }
    }

    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        let status = response.statusCode

        print("[\(status)] \(response.url?.absoluteString ?? "?")")

        if let bodyString = String(data: data, encoding: .utf8) {
            let preview = bodyString.count > 500
                ? String(bodyString.prefix(500)) + "... (обрезано)"
                : bodyString
            print("   Response: \(preview)")
        }

        print("")
    }

    private func logError(_ error: ApiError) {
        print("[ERROR] \(error.errorDescription ?? "unknown")")
        print("")
    }
}
