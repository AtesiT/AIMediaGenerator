import Foundation

// MARK: - Auth Models

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

// MARK: - AuthService

final class AuthService {

    static let shared = AuthService()
    private init() {}

    private let dolaBaseURL = "https://nebulaapps.site/dola"
    private let pixverseBaseURL = "https://nebulaapps.site/pixverse"

    // Проверка здоровья Dola API
    func checkDolaHealth() async throws -> Bool {
        struct HealthResponse: Decodable { let status: String }
        let response = try await NetworkService.shared.request(
            baseURL: dolaBaseURL,
            path: "/health",
            responseType: HealthResponse.self
        )
        return response.status == "ok"
    }

    // Проверка здоровья PixVerse API
    func checkPixVerseHealth() async throws -> Bool {
        struct HealthResponse: Decodable { let status: String }
        let response = try await NetworkService.shared.request(
            baseURL: pixverseBaseURL,
            path: "/health",
            responseType: HealthResponse.self
        )
        return response.status == "ok"
    }
}
