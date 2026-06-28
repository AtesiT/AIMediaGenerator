import Foundation

enum Config {
    
    // MARK: - API URLs
    
    static let dolaBaseURL = "https://nebulaapps.site/dola"
    static let pixverseBaseURL = "https://nebulaapps.site/pixverse"
    
    // MARK: - Authentication
    
    static let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJzaGFyb3ZfMTk5OUBsaXN0LnJ1Iiwicm9sZSI6IkFETUlOIiwiZXhwIjo0OTM1MjA4NjcxLCJpYXQiOjE3ODE2MDg2NzEsInR5cGUiOiJhY2Nlc3MifQ.0GRnZq1LZA__0G0tYEsPER8lQiCiX_myE6_T_nMwUmc"
    
    static let appId = "com.test.test"
    
    // MARK: - Apphud
    
    static let apphudApiKey = "app_FmCjFTwjWpcLSafxT8vCDeVffJyfFS"
    static let apphudPaywallId = "main"
    
    // MARK: - Network
    
    static let defaultTimeout: TimeInterval = 30
    static let downloadTimeout: TimeInterval = 60
    static let pollingInterval: TimeInterval = 3.0
    static let maxPollingDuration: TimeInterval = 300.0
}
