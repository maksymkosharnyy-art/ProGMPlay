import SwiftUI
import StoreKit
import Combine

struct PaywallViewPGM: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: ViewModelPGM
    @EnvironmentObject var iap: IAPManagerPGM
    
    let themeName: String
    let onBuy: (SKProduct) -> Void
    
    @State private var showPurchaseConfirm = false
    @State private var showPurchaseSuccess = false
    @State private var showPurchaseError = false
    @State private var purchaseErrorMessage: String = ""
    @State private var showRestoreAlert = false
    @State private var restoreMessage: String?
    
    private var isSmallScreen: Bool {
        UIScreen.main.bounds.height < 700
    }
    
    // СТРОГИЙ МАППИНГ БЕЗ ЗНАЧЕНИЙ ПО УМОЛЧАНИЮ
    private func getProductId(for theme: String) -> String? {
        switch theme {
        case "Royal Amethyst": return "premium_theme_royal_amethyst"
        case "Midnight Onyx":  return "premium_theme_midnight_onyx"
        default: return nil
        }
    }
    
    private var product: SKProduct? {
        guard let productId = getProductId(for: themeName) else { return nil }
        return iap.products.first(where: { $0.productIdentifier == productId })
    }
    
    var body: some View {
        ZStack {
            ThemePGM.primaryBackground(for: themeName).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: isSmallScreen ? 16 : 32) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(12)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Icon
                    ZStack {
                        Circle()
                            .fill(ThemePGM.goldGradient.opacity(0.2))
                            .frame(width: isSmallScreen ? 100 : 140, height: isSmallScreen ? 100 : 140)
                        
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: isSmallScreen ? 44 : 64))
                            .foregroundStyle(ThemePGM.goldGradient)
                            .shadow(color: ThemePGM.accentColor(for: themeName).opacity(0.5), radius: 15)
                    }
                    .padding(.top, isSmallScreen ? 10 : 20)
                    
                    VStack(spacing: isSmallScreen ? 8 : 12) {
                        Text(themeName)
                            .font(.system(size: isSmallScreen ? 28 : 34, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("Premium Visual Experience")
                            .font(isSmallScreen ? .subheadline : .headline)
                            .foregroundColor(ThemePGM.accentColor(for: themeName))
                    }
                    
                    // Benefits
                    VStack(alignment: .leading, spacing: isSmallScreen ? 16 : 24) {
                        BenefitRowPGM(icon: "sparkles", text: "Unique color palette for board & UI", themeName: themeName)
                        BenefitRowPGM(icon: "crown.fill", text: "Exclusive premium theme status", themeName: themeName)
                        BenefitRowPGM(icon: "eye.fill", text: "High-contrast design for better focus", themeName: themeName)
                        BenefitRowPGM(icon: "checkmark.seal.fill", text: "One-time purchase, yours forever", themeName: themeName)
                    }
                    .padding(.horizontal, isSmallScreen ? 24 : 32)
                    
                    Spacer(minLength: isSmallScreen ? 20 : 40)
                    
                    // Buy Button
                    if let product = product {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showPurchaseConfirm = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Buy for \(product.localizedPriceVE)")
                                    .font(isSmallScreen ? .headline.weight(.bold) : .title3.weight(.bold))
                            }
                            .foregroundColor(ThemePGM.deepPurple)
                            .padding(.horizontal, 40)
                            .padding(.vertical, isSmallScreen ? 18 : 22)
                            .background(ThemePGM.goldGradient)
                            .cornerRadius(isSmallScreen ? 20 : 24)
                            .shadow(color: ThemePGM.accentColor(for: themeName).opacity(0.4), radius: 15, y: 8)
                        }
                        .interactiveButtonStylePGM()
                        .padding(.horizontal, 24)
                    } else {
                        ProgressView()
                            .tint(ThemePGM.accentColor(for: themeName))
                    }
                    
                    Button {
                        iap.restorePurchases()
                    } label: {
                        Text("Restore Purchases")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.bottom, 20)
                }
            }
        
            // Alert Overlays
            if showPurchaseConfirm {
                PurchaseConfirmAlertPGM(
                    themeName: themeName,
                    price: product?.localizedPriceVE ?? "",
                    isLoading: iap.isLoading,
                    onBuy: {
                        showPurchaseConfirm = false
                        if let p = product {
                            iap.purchase(p)
                        }
                    },
                    onCancel: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showPurchaseConfirm = false
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(100)
            }
            
            if showPurchaseSuccess {
                PurchaseResultAlertPGM(
                    isSuccess: true,
                    message: "\(themeName) theme unlocked! Enjoy your new look.",
                    onDismiss: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showPurchaseSuccess = false
                            viewModel.selectedTheme = themeName
                            dismiss()
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(100)
            }
            
            if showPurchaseError {
                PurchaseResultAlertPGM(
                    isSuccess: false,
                    message: purchaseErrorMessage,
                    onDismiss: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showPurchaseError = false
                            dismiss()
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(100)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            iap.fetchProducts()
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage ?? "")
        }
        .onReceive(iap.$errorMessage.compactMap { $0 }) { error in
            if iap.isRestoring {
                restoreMessage = error
                showRestoreAlert = true
                iap.isRestoring = false
                iap.isLoading = false
            }
        }
        .onReceive(iap.$purchasedProductIds) { ids in
            // Only trigger restore success if restore is actively in progress
            // and the purchased IDs set isn't empty (i.e. something was actually restored)
            if iap.isRestoring && !ids.isEmpty {
                restoreMessage = "Purchases restored successfully!"
                showRestoreAlert = true
                iap.isRestoring = false
                iap.isLoading = false
            }
        }
        .onReceive(iap.$lastPurchasedProductId.compactMap { $0 }) { productId in
            // Надежно получаем ID, соответствующий открытой теме
            guard let expectedId = getProductId(for: themeName), productId == expectedId else { return }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showPurchaseSuccess = true
                iap.lastPurchasedProductId = nil
            }
        }
        .onReceive(iap.$lastPurchaseError.compactMap { $0 }) { error in
            guard showPurchaseConfirm else { return }
            purchaseErrorMessage = error.localizedDescription
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showPurchaseConfirm = false
                showPurchaseError = true
                iap.lastPurchaseError = nil
            }
        }
    }
}

struct BenefitRowPGM: View {
    let icon: String
    let text: String
    let themeName: String
    
    private var isSmallScreen: Bool {
        UIScreen.main.bounds.height < 700
    }
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(ThemePGM.accentColor(for: themeName))
                .frame(width: 40)
            
            Text(text)
                .font(isSmallScreen ? .subheadline : .headline)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
