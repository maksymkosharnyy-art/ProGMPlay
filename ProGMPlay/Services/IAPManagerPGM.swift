import Foundation
import StoreKit
import Combine

final class IAPManagerPGM: NSObject, ObservableObject {
    static let shared = IAPManagerPGM()
    
    @Published var products: [SKProduct] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isRestoring: Bool = false
    @Published var lastPurchasedProductId: String?
    @Published var lastPurchaseError: Error?
    @Published var lastAwardedCode: String?
    
    private static var observerAdded = false
    private var productsRequest: SKProductsRequest?
    
    @Published private(set) var purchasedProductIds: Set<String> = []

    private let productIds: Set<String> = [
        "premium_theme_royal_amethyst",
        "premium_theme_midnight_onyx"
    ]
    
    private override init() {
        super.init()
        if !Self.observerAdded {
            SKPaymentQueue.default().add(self)
            Self.observerAdded = true
        }
        loadPurchased()
    }
    private func loadPurchased() {
        if let arr = UserDefaults.standard.array(forKey: "purchasedProductIdsPGM") as? [String] {
            purchasedProductIds = Set(arr)
        }
    }
    private func savePurchased() {
        UserDefaults.standard.set(Array(purchasedProductIds), forKey: "purchasedProductIdsPGM")
    }
    
    func restorePurchases() {
        isLoading = true
        isRestoring = true
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    deinit { SKPaymentQueue.default().remove(self) }
    
    func isPurchased(_ productId: String) -> Bool {
        purchasedProductIds.contains(productId)
    }
    
    func fetchProducts() {
        guard !isLoading else { return }
        isLoading = true
        
        productsRequest?.cancel()
        let req = SKProductsRequest(productIdentifiers: productIds)
        self.productsRequest = req
        req.delegate = self
        req.start()
    }
    
    func purchase(_ product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else {
            errorMessage = "Purchases are disabled on this device"
            lastPurchaseError = nil
            lastPurchasedProductId = nil
            return
        }
        isLoading = true
        SKPaymentQueue.default().add(SKPayment(product: product))
    }
    
    private func handlePurchased(_ identifier: String) {
        self.isLoading = false
        self.purchasedProductIds.insert(identifier)
        self.savePurchased()
        self.errorMessage = nil
    }
    
    private func handleFailed(_ error: Error?) {
        DispatchQueue.main.async {
            if let skErr = error as? SKError,
               skErr.code == .paymentCancelled {
                self.isLoading = false
                return
            }
            
            self.lastPurchaseError = error
            self.errorMessage      = error?.localizedDescription
            self.lastPurchasedProductId = nil
            self.isLoading         = false
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        for t in queue.transactions {
            let id = t.payment.productIdentifier
            self.purchasedProductIds.insert(id)
        }
        savePurchased()
        
        DispatchQueue.main.async {
            if queue.transactions.isEmpty {
                self.errorMessage = "No purchases to restore"
            } else {
                self.errorMessage = "Purchases restored successfully!"
            }

            self.isRestoring = false
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}

extension IAPManagerPGM: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products.sorted { $0.price.doubleValue < $1.price.doubleValue }
            self.isLoading = false
            self.productsRequest = nil
            if !response.invalidProductIdentifiers.isEmpty {
                print("Invalid products: \(response.invalidProductIdentifiers)")
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            self.productsRequest = nil
        }
    }
}

extension IAPManagerPGM: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions txs: [SKPaymentTransaction]) {
        for tx in txs {
            switch tx.transactionState {
            case .purchased:
                DispatchQueue.main.async {
                    let id = tx.payment.productIdentifier
                    self.purchasedProductIds.insert(id)
                    self.savePurchased()
                    self.lastPurchasedProductId = id
                    self.isLoading = false
                    SKPaymentQueue.default().finishTransaction(tx)
                }
            case .failed:
                handleFailed(tx.error)
                SKPaymentQueue.default().finishTransaction(tx)
            case .restored:
                DispatchQueue.main.async {
                    let id = tx.payment.productIdentifier
                    self.purchasedProductIds.insert(id)
                    self.savePurchased()
                    self.lastPurchasedProductId = id
                    self.isLoading = false
                    SKPaymentQueue.default().finishTransaction(tx)
                }
            case .deferred:
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Awaiting approval"
                }
            default: break
            }
        }
    }
}

extension SKProduct {
    var localizedPriceVE: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = self.priceLocale
        return f.string(from: self.price) ?? ""
    }
    
    var localizedNameVE: String {
        return self.localizedTitle
    }
}
