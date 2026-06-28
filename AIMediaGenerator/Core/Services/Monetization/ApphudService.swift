import SwiftUI
import ApphudSDK
import Combine

final class ApphudService: ObservableObject {

    static let shared = ApphudService()
    private init() {}

    private let apiKey = Config.apphudApiKey
    private let paywallId = Config.apphudPaywallId

    @Published var isSubscribed: Bool = false
    @Published var isLoading: Bool = false
    @Published var currentPaywall: ApphudPaywall? = nil
    @Published var products: [ApphudProduct] = []

    var userId: String {
        Apphud.userID()
    }

    // MARK: - Инициализация

    func initialize() {
        Apphud.start(apiKey: apiKey)
        checkSubscriptionStatus()
        loadPaywall()
    }

    // MARK: - Проверка подписки

    func checkSubscriptionStatus() {
        isSubscribed = Apphud.hasActiveSubscription()
        print("💎 Subscription status: \(isSubscribed)")
    }

    // MARK: - Загрузка Paywall через placements (3.3.x API)

    func loadPaywall() {
        Task {
            await performLoadPaywall()
        }
    }

    @MainActor
    private func performLoadPaywall() async {
        // В SDK 3.3.x используем fetchPlacements
        Apphud.fetchPlacements { [weak self] placements, error in
            guard let self else { return }

            if let error {
                print("⚠️ Placements error: \(error.localizedDescription)")
                return
            }

            // Ищем paywall по нашему paywallId
            let allPaywalls = placements.compactMap { $0.paywall }

            if let paywall = allPaywalls.first(where: {
                $0.identifier == self.paywallId
            }) ?? allPaywalls.first {
                DispatchQueue.main.async {
                    self.currentPaywall = paywall
                    self.products = paywall.products
                    print("✅ Paywall loaded: \(paywall.identifier), products: \(paywall.products.count)")
                }
            } else {
                print("⚠️ No paywalls found in placements")
            }
        }
    }

    // MARK: - Покупка

    func purchase(product: ApphudProduct) async -> Bool {
        await MainActor.run { isLoading = true }

        let result = await Apphud.purchase(product)

        await MainActor.run {
            isLoading = false
            if result.success {
                isSubscribed = true
                print("✅ Purchase successful")
            } else if let error = result.error {
                print("❌ Purchase failed: \(error.localizedDescription)")
            }
        }

        return result.success
    }

    // MARK: - Restore

    func restorePurchases() async -> Bool {
        await MainActor.run { isLoading = true }

        let result = await Apphud.restorePurchases()

        await MainActor.run {
            isLoading = false
            isSubscribed = Apphud.hasActiveSubscription()
            print("🔄 Restore result: \(isSubscribed)")
        }

        return isSubscribed
    }
}
