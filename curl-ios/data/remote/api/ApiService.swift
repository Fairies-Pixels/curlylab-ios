import Foundation

final class ApiService {
    static let shared = ApiService()
    
    private let baseURL = "https://curlylab.ru:8080"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        var request = try buildRequest(path, method: "GET", queryItems: queryItems)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await perform(request)
    }
    
    func post<T: Decodable, U: Encodable>(_ path: String, body: U?) async throws -> T {
        var request = try buildRequest(path, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        return try await perform(request)
    }
    
    func put<T: Decodable, U: Encodable>(_ path: String, body: U?) async throws -> T {
        var request = try buildRequest(path, method: "PUT")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        return try await perform(request)
    }
    
    func delete<T: Decodable>(_ path: String) async throws -> T {
        var request = try buildRequest(path, method: "DELETE")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await perform(request)
    }
    
    private func buildRequest(_ path: String, method: String, queryItems: [URLQueryItem]? = nil) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw ApiError.invalidURL
        }
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
    
    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.unknown
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw ApiError.http(code: httpResponse.statusCode, message: String(data: data, encoding: .utf8))
            }
            
            if data.isEmpty, T.self == EmptyResponse.self {
                return EmptyResponse() as! T
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

struct EmptyResponse: Decodable {}
