import Foundation

// MARK: - Ошибки сети

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int, String?)
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error \(code): \(message ?? "Unknown")"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

// MARK: - NetworkService

final class NetworkService {

    static let shared = NetworkService()
    private init() {}

    // Bearer token
    private let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJzaGFyb3ZfMTk5OUBsaXN0LnJ1Iiwicm9sZSI6IkFETUlOIiwiZXhwIjo0OTM1MjA4NjcxLCJpYXQiOjE3ODE2MDg2NzEsInR5cGUiOiJhY2Nlc3MifQ.0GRnZq1LZA__0G0tYEsPER8lQiCiX_myE6_T_nMwUmc"

    private let appId = "com.test.test"
    private let userId = "test_user_001"

    // MARK: - Базовый запрос

    func request<T: Decodable>(
        baseURL: String,
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        responseType: T.Type
    ) async throws -> T {

        // Собираем URL
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }

        // Добавляем обязательные query параметры
        var items = queryItems
        items.append(URLQueryItem(name: "user_id", value: userId))
        items.append(URLQueryItem(name: "app_id", value: appId))
        components.queryItems = items.isEmpty ? nil : items

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        // Собираем запрос
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        // Тело запроса
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }

        // Выполняем запрос
        let (data, response) = try await URLSession.shared.data(for: request)

        // Проверяем HTTP статус
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            // Пытаемся вытащить сообщение об ошибке из тела
            let message = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(httpResponse.statusCode, message)
        }

        // Декодируем ответ
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    // MARK: - Multipart запрос (для загрузки изображений)

    func multipartRequest<T: Decodable>(
        baseURL: String,
        path: String,
        queryItems: [URLQueryItem] = [],
        fields: [String: String],
        imageFields: [String: Data],
        responseType: T.Type
    ) async throws -> T {

        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }

        var items = queryItems
        items.append(URLQueryItem(name: "user_id", value: userId))
        items.append(URLQueryItem(name: "app_id", value: appId))
        components.queryItems = items

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        request.timeoutInterval = 60

        // Собираем multipart body
        var body = Data()

        // Текстовые поля
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Поля с изображениями
        for (key, imageData) in imageFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append(
                "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\r\n".data(using: .utf8)!
            )
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        //  Здесь обработка ответа
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            let message = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(httpResponse.statusCode, message)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
