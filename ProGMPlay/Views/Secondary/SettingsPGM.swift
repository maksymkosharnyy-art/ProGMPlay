import SwiftUI
import StoreKit
import Combine

struct PaywallThemeItem: Identifiable {
    let id: String
}

// MARK: - Settings View
struct SettingsPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var iap: IAPManagerPGM
    
    @State private var showAbout = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage: String?
    
    // ИСПОЛЬЗУЕМ ITEM ВМЕСТО BOOL, ЧТОБЫ ИЗБЕЖАТЬ БАГОВ С ЗАГРУЗКОЙ ДАННЫХ
    @State private var activePaywall: PaywallThemeItem?
    
    let themes = ["Classic Gold", "Royal Amethyst", "Midnight Onyx"]
    
    private func productIdForTheme(_ theme: String) -> String? {
        switch theme {
        case "Royal Amethyst": return "premium_theme_royal_amethyst"
        case "Midnight Onyx": return "premium_theme_midnight_onyx"
        default: return nil
        }
    }
    
    private func priceForTheme(_ theme: String) -> String {
        guard let productId = productIdForTheme(theme) else { return "Free" }
        if iap.isPurchased(productId) { return "Owned" }
        if let product = iap.products.first(where: { $0.productIdentifier == productId }) {
            return product.localizedPriceVE
        }
        return "..."
    }
    
    private func isPaidTheme(_ theme: String) -> Bool {
        return productIdForTheme(theme) != nil
    }
    
    private func isThemeUnlocked(_ theme: String) -> Bool {
        if theme == "Classic Gold" { return true }
        guard let productId = productIdForTheme(theme) else { return true }
        return iap.isPurchased(productId)
    }
    
    private func repairStorage() {
        let key = "purchasedProductIdsPGM"
        if let corruptedString = UserDefaults.standard.string(forKey: key) {
            let ids = corruptedString.components(separatedBy: ",").filter { !$0.isEmpty }
            UserDefaults.standard.set(ids, forKey: key)
            iap.fetchProducts()
        }
    }
    
    private var allThemesPurchased: Bool {
        themes.filter { isPaidTheme($0) }.allSatisfy { isThemeUnlocked($0) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if !allThemesPurchased {
                            PremiumBannerPGM()
                                .padding(.horizontal, 32)
                        }
                        
                        // MARK: - App Theme
                        VStack(alignment: .leading, spacing: 16) {
                            Text("App Theme")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(Array(themes.enumerated()), id: \.element) { index, theme in
                                        Button {
                                            handleThemeTap(theme)
                                        } label: {
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    Rectangle()
                                                        .fill(themeGradient(for: theme))
                                                        .frame(width: 130, height: 90)
                                                        .cornerRadius(16)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(viewModel.selectedTheme == theme ? ThemePGM.accentColor(for: theme) : Color.clear, lineWidth: 3)
                                                        )
                                                    
                                                    if isThemeUnlocked(theme) && viewModel.selectedTheme == theme {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.white)
                                                            .font(.title2)
                                                    }
                                                    
                                                    if isPaidTheme(theme) && !isThemeUnlocked(theme) {
                                                        Image(systemName: "lock.fill")
                                                            .foregroundColor(.white.opacity(0.7))
                                                            .font(.caption)
                                                            .padding(6)
                                                            .background(Color.black.opacity(0.5))
                                                            .clipShape(Circle())
                                                    }
                                                }
                                                
                                                Text(theme)
                                                    .font(.caption)
                                                    .foregroundColor(viewModel.selectedTheme == theme ? ThemePGM.accentColor(for: theme) : .gray)
                                                
                                                let price = priceForTheme(theme)
                                                Text(price)
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(
                                                        price == "Free" || price == "Owned" ? .green : ThemePGM.accentColor(for: theme)
                                                    )
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 3)
                                                    .background(
                                                        (price == "Free" || price == "Owned" ? Color.green : ThemePGM.accentColor(for: theme)).opacity(0.15)
                                                    )
                                                    .clipShape(Capsule())
                                            }
                                        }
                                        .interactiveButtonStylePGM()
                                    }
                                }
                                .padding(.horizontal, 32)
                            }
                        }
                        
                        // MARK: - Actions
                        VStack(spacing: 12) {
                            Button {
                                iap.restorePurchases()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                                    Text("Restore Purchases")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    if iap.isLoading && iap.isRestoring {
                                        ProgressView()
                                            .tint(ThemePGM.accentColor(for: viewModel.selectedTheme))
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                            }
                            .interactiveButtonStylePGM()
                            .disabled(iap.isLoading)
                            
                            Button {
                                requestReview()
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                                    Text("Rate App")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                            }
                            .interactiveButtonStylePGM()
                            
                            Button {
                                showAbout = true
                            } label: {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                                    Text("About ProGM Play")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                            }
                            .interactiveButtonStylePGM()
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer(minLength: 40)
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .foregroundColor(.white)
                    }
                }
                .onAppear {
                    repairStorage()
                    iap.fetchProducts()
                }
                .fullScreenCover(isPresented: $showAbout) {
                    AboutPGM()
                }
                // ТЕПЕРЬ ПЕЙВОЛ ПРИВЯЗАН К КОНКРЕТНОМУ ITEM
                .fullScreenCover(item: $activePaywall) { themeItem in
                    PaywallViewPGM(themeName: themeItem.id) { product in
                        iap.purchase(product)
                    }
                }
                .alert(isPresented: $showRestoreAlert) {
                    Alert(
                        title: Text("Restore Purchases"),
                        message: Text(restoreMessage ?? ""),
                        dismissButton: .default(Text("OK"))
                    )
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
                    if iap.isRestoring && !ids.isEmpty {
                        restoreMessage = "Purchases restored successfully!"
                        showRestoreAlert = true
                        iap.isRestoring = false
                        iap.isLoading = false
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Handlers
    private func handleThemeTap(_ theme: String) {
        if isThemeUnlocked(theme) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.selectedTheme = theme
            }
        } else {
            // Мгновенно передаем название темы, исключая гонку состояний
            activePaywall = PaywallThemeItem(id: theme)
        }
    }
    
    func themeGradient(for name: String) -> LinearGradient {
        switch name {
        case "Classic Gold":
            return ThemePGM.goldGradient
        case "Royal Amethyst":
            return LinearGradient(colors: [ThemePGM.royalAmethyst, ThemePGM.deepPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [ThemePGM.midnightOnyx, ThemePGM.navyBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Premium Banner

struct PremiumBannerPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @State private var animateGradient = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 36))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Discover New Themes")
                    .font(.title3.weight(.black))
                    .foregroundColor(.white)
                
                Text("Unlock unique visual styles for your board and interface.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundColor(.white)
        }
        .padding(20)
        .background(
            LinearGradient(colors: [ThemePGM.accentColor(for: viewModel.selectedTheme), ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.7)], startPoint: animateGradient ? .topLeading : .bottomTrailing, endPoint: animateGradient ? .bottomTrailing : .topLeading)
        )
        .cornerRadius(20)
        .shadow(color: ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), radius: 12, y: 6)
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Alerts

struct PurchaseConfirmAlertPGM: View {
    let themeName: String
    let price: String
    let isLoading: Bool
    let onBuy: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Confirm Purchase")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Would you like to unlock the **\(themeName)** theme for \(price)?")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    Button(action: onBuy) {
                        HStack {
                            if isLoading { ProgressView().tint(.white) }
                            Text(isLoading ? "Processing..." : "Buy Now")
                        }
                        .font(.headline.weight(.bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .disabled(isLoading)
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.body.weight(.medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .disabled(isLoading)
                }
            }
            .padding(32)
            .background(Color(hex: "#1A1A1A"))
            .cornerRadius(28)
            .padding(.horizontal, 40)
        }
    }
}

struct PurchaseResultAlertPGM: View {
    let isSuccess: Bool
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(isSuccess ? .green : .red)
                
                Text(isSuccess ? "Success!" : "Error")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Button(action: onDismiss) {
                    Text("OK")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                }
            }
            .padding(32)
            .background(Color(hex: "#1A1A1A"))
            .cornerRadius(28)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - About

struct AboutPGM: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            ThemePGM.midnightOnyx.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image("mainLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    Text("ProGM Play")
                        .font(.largeTitle.weight(.heavy))
                        .foregroundColor(.white)
                    
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text("ProGM Play is designed to teach you the logic and ideas behind Grandmaster moves. We value your privacy; no personal game data is shared without explicit permission. All AI analysis is processed securely.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(ThemePGM.goldGradient)
                        .cornerRadius(20)
                }
                .interactiveButtonStylePGM()
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
