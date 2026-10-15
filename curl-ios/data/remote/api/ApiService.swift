import Foundation

final class ApiService {
    static let shared = ApiService()

    private let baseURL = "https://dummyjson.com"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
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
}
