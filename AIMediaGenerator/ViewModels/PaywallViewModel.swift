import SwiftUI
import ApphudSDK
import Combine
internal import StoreKit

final class PaywallViewModel: ObservableObject {

    @Published var showCloseButton = false
    @Published var isYearlySelected = true
    @Published var isLoading = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""

    // Apphud
    @Published var yearlyProduct: ApphudProduct? = nil
    @Published var monthlyProduct: ApphudProduct? = nil

    // Цены
    @Published var yearlyPriceText: String = "$69.99"
    @Published var yearlyWeeklyPriceText: String = "$1.27 / week"
    @Published var monthlyPriceText: String = "$7.99"
    @Published var monthlyWeeklyPriceText: String = "$1.99 / week"

    private let apphudService = ApphudService.shared

    // MARK: - Init

    func onAppear() {
        startTimer()
        loadProducts()
    }

    // MARK: - Таймер крестика

    func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.linear(duration: 0.3)) {
                self.showCloseButton = true
            }
        }
    }

    // MARK: - Загрузка продуктов

    private func loadProducts() {
        let products = apphudService.products

        if products.isEmpty {
            // Продукты ещё не загружены — ждём
            apphudService.loadPaywall()
            observeProducts()
            return
        }

        mapProducts(products)
    }

    private func observeProducts() {
        // Повторная проверка через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            let products = ApphudService.shared.products
            if !products.isEmpty {
                self?.mapProducts(products)
            }
        }
    }

    private func mapProducts(_ products: [ApphudProduct]) {
        for product in products {
            guard let skProduct = product.skProduct else { continue }

            let price = skProduct.price.doubleValue
            let locale = skProduct.priceLocale
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = locale

            let priceString = formatter.string(from: skProduct.price) ?? "\(price)"

            // Определяем тип продукта по ID или периоду
            let productId = product.productId.lowercased()

            if productId.contains("year") || productId.contains("annual") {
                yearlyProduct = product
                yearlyPriceText = priceString
                let weeklyPrice = price / 52
                yearlyWeeklyPriceText = "\(formatter.string(from: NSNumber(value: weeklyPrice)) ?? "") / week"
            } else if productId.contains("month") {
                monthlyProduct = product
                monthlyPriceText = priceString
                let weeklyPrice = price / 4
                monthlyWeeklyPriceText = "\(formatter.string(from: NSNumber(value: weeklyPrice)) ?? "") / week"
            }
        }

        print("💰 Products mapped: yearly=\(yearlyProduct?.productId ?? "nil"), monthly=\(monthlyProduct?.productId ?? "nil")")
    }

    // MARK: - Покупка

    func handleUnlock(completion: @escaping () -> Void) {
        let product = isYearlySelected ? yearlyProduct : monthlyProduct

        guard let product else {
            // Продукт не загружен — пробуем без конкретного продукта
            print("⚠️ Product not loaded yet")
            errorMessage = "Products are loading. Please try again."
            showErrorAlert = true
            return
        }

        isLoading = true

        Task {
            let success = await apphudService.purchase(product: product)

            await MainActor.run {
                isLoading = false
                if success {
                    completion()
                } else {
                    errorMessage = "Purchase failed. Please try again."
                    showErrorAlert = true
                }
            }
        }
    }

    // MARK: - Restore

    func restorePurchases(completion: @escaping () -> Void) {
        isLoading = true

        Task {
            let restored = await apphudService.restorePurchases()

            await MainActor.run {
                isLoading = false
                if restored {
                    completion()
                } else {
                    errorMessage = "No active subscriptions found."
                    showErrorAlert = true
                }
            }
        }
    }
}
