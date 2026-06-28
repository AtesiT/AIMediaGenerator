import Foundation

// MARK: - Empty для Void-кейсов

struct Empty: Equatable {}

// MARK: - LoadingState

enum LoadingState<T: Equatable>: Equatable {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(String)
    
    // MARK: - Computed Properties
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
    
    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}
