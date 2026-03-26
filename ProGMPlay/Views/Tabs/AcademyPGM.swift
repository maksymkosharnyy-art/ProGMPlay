import SwiftUI

struct AcademyPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @State private var selectedCategory: String = "All"
    @State private var selectedArticle: AcademyArticlePGM?
    @State private var searchText: String = ""

    let categories = ["All", "Openings", "Middlegame", "Endgame", "GM Psychology"]

    var filteredArticles: [AcademyArticlePGM] {
        let base = selectedCategory == "All" 
            ? viewModel.academyArticles 
            : viewModel.academyArticles.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return base
        }
        return base.filter { 
            $0.title.localizedCaseInsensitiveContains(searchText) || 
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var pinnedArticle: AcademyArticlePGM? {
        viewModel.academyArticles.first(where: { $0.isPinned })
    }

    var body: some View {
        ZStack(alignment: .top) {
            ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Refined Floating Search Bar
                searchBar
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .zIndex(10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        if searchText.isEmpty {
                            // Weekly Wisdom Pinned Section
                            if let pinned = pinnedArticle {
                                weeklyWisdomBanner(article: pinned)
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                            }

                            VStack(alignment: .leading, spacing: 16) {
                                Text("Knowledge Categories")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                categoryFilter
                            }
                        }

                        // Main Article List
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                Text(searchText.isEmpty ? (selectedCategory == "All" ? "Featured Longreads" : selectedCategory) : "Search Results")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(filteredArticles.count) Articles")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                            }
                            .padding(.horizontal)

                            LazyVStack(spacing: 20) {
                                ForEach(filteredArticles) { article in
                                    LongreadCardPGM(article: article) {
                                        selectedArticle = article
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 140)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .sheet(item: $selectedArticle) { article in
            ArticleReaderPGM(article: article) {
                viewModel.markArticleRead(article)
            }
            .environmentObject(viewModel)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
            
            TextField("Search articles...", text: $searchText)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.3))
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ThemePGM.goldGradient.opacity(0.3), lineWidth: 1)
        )
    }


    // MARK: - Weekly Wisdom Banner (Pinned Section)

        private func weeklyWisdomBanner(article: AcademyArticlePGM) -> some View {
            Button {
                selectedArticle = article
            } label: {
                ZStack(alignment: .bottomLeading) {
                    
                    // 1. Бронебойный фон: Rectangle строго держит ширину,
                    // а overlay не дает картинке распирать ZStack.
                    Rectangle()
                        .fill(ThemePGM.midnightOnyx)
                        .overlay(
                            Image(article.imageName)
                                .resizable()
                                .scaledToFill()
                                .opacity(0.6)
                        )
                        .overlay(
                            LinearGradient(
                                colors: [.clear, (viewModel.selectedTheme == "Midnight Onyx" ? ThemePGM.midnightOnyx : ThemePGM.deepPurple).opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipped()
                    
                    // 2. Контент карточки
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Weekly Wisdom", systemImage: "star.fill")
                                .font(.system(size: 10, weight: .black))
                                .textCase(.uppercase)
                                .foregroundColor(ThemePGM.deepPurple)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(ThemePGM.goldGradient)
                                .clipShape(Capsule())

                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                Text(article.readTime)
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tactical Principle:")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                            
                            Text(article.title)
                                .font(.system(size: 26, weight: .black))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HStack {
                            Text("Enter the Academy")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
                .frame(maxWidth: .infinity) // Жестко ограничиваем ширину
                .frame(height: 220)
                .cornerRadius(24)
                // Убраны все конфликтующие внутренние padding'и. Отступ задается в главном View.
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ThemePGM.goldGradient.opacity(0.4), lineWidth: 1.5)
                )
                .shadow(color: ThemePGM.royalAmethyst.opacity(0.5), radius: 20, y: 10)
            }
            .buttonStyle(PlainButtonStyle())
            .interactiveButtonStylePGM()
        }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    } label: {
                        Text(category)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(selectedCategory == category ? ThemePGM.deepPurple : .white.opacity(0.7))
                            .padding(.horizontal, 22)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    if selectedCategory == category {
                                        ThemePGM.goldGradient
                                            .clipShape(Capsule())
                                    } else {
                                        Color.white.opacity(0.06)
                                            .clipShape(Capsule())
                                    }
                                }
                            )
                            .overlay(
                                Capsule()
                                    .stroke(selectedCategory == category ? ThemePGM.accentColor(for: viewModel.selectedTheme) : Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Longread Card

struct LongreadCardPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let article: AcademyArticlePGM
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Premium Styled Thumbnail
                ZStack {
                    ThemePGM.navyBlue
                    
                    Image(article.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.5), lineWidth: 1.5)
                }
                .frame(width: 100, height: 100)
                .cornerRadius(16)
                .shadow(color: ThemePGM.royalAmethyst.opacity(0.3), radius: 8, y: 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(article.category.uppercased())
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                            .tracking(1)
                        
                        Spacer()
                        
                        if article.progress >= 1.0 {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("READ")
                            }
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.green)
                        }
                    }

                    Text(article.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text(article.readTime)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.5))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.5))
                    }
                    
                    // Mini progress bar
                    if article.progress > 0 && article.progress < 1.0 {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.1)).frame(height: 3)
                                Capsule().fill(ThemePGM.goldGradient).frame(width: geo.size.width * article.progress, height: 3)
                            }
                        }
                        .frame(height: 3)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Article Reader

struct ArticleReaderPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let article: AcademyArticlePGM
    let onFinishReading: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var aiAnalysis: String = ""
    @State private var isLoadingAnalysis = false
    @State private var showAnalysis = false

    private let aiService = AIServicePGM()
    private let fallbackService = FallbackServicePGM()

    var body: some View {
        ZStack(alignment: .top) {
            ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Hero Header Image
                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .fill(ThemePGM.navyBlue)
                            .overlay(
                                Image(article.imageName)
                                    .resizable()
                                    .scaledToFill()
                            )
                            .overlay(
                                LinearGradient(
                                    colors: [.clear, (viewModel.selectedTheme == "Midnight Onyx" ? ThemePGM.midnightOnyx : ThemePGM.deepPurple)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(article.category.uppercased())
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                                .tracking(2)
                            
                            Text(article.title)
                                .font(.system(size: 34, weight: .black))
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(24)
                    }
                    .frame(maxWidth: .infinity) // Жесткий лимит
                    .frame(height: 260)
                    .cornerRadius(24)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .shadow(color: .black.opacity(0.4), radius: 15, y: 10)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Metadata Row
                        HStack(spacing: 20) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                Text(article.readTime)
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "book.fill")
                                Text("ProGM Original")
                            }
                            Spacer()
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        .padding(.bottom, 8)

                        // Content
                        Text(article.content)
                            .font(.system(size: 18, weight: .regular, design: .serif))
                            .lineSpacing(10)
                            .foregroundColor(.white.opacity(0.9))
                        
                        // Stylized "Infographic" Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Key Masterclass Takeaways")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                takeawayRow(title: "Strategic Depth", desc: "Understanding the underlying mechanics of this pattern is crucial for high-level play.")
                                takeawayRow(title: "Positional Mastery", desc: "Small advantages in chess accumulate over time and lead to a decisive victory.")
                                takeawayRow(title: "Grandmaster Intuition", desc: "Daily practice of these longreads will sharpen your pattern recognition engine.")
                            }
                        }
                        .padding(24)
                        .background(ThemePGM.navyBlue.opacity(0.5))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(ThemePGM.goldGradient.opacity(0.3), lineWidth: 1))
                        .padding(.vertical, 20)

                        // Conclusion / Final Note
                        Text("Conclusion")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("Mastering chess requires a combination of deep study and vigorous practice. This article should serve as your foundation for exploring these concepts in your own matches. Remember, even the greatest GMs were once beginners who never stopped learning.")
                            .font(.system(size: 18, weight: .regular, design: .serif))
                            .lineSpacing(10)
                            .foregroundColor(.white.opacity(0.7))

                        // AI Analysis Section
                        aiAnalysisSection

                        Button {
                            onFinishReading()
                            dismiss()
                        } label: {
                            Text("Mark as Complete")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(ThemePGM.deepPurple)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(ThemePGM.goldGradient)
                                .cornerRadius(16)
                                .shadow(color: ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.top, 20)
                        .interactiveButtonStylePGM()

                        Spacer(minLength: 60)
                    }
                    .padding(24)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Close Button
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                }
                .padding(20)
            }
        }
    }

    // MARK: - AI Analysis Section

    private var aiAnalysisSection: some View {
        VStack(spacing: 16) {
            if !showAnalysis {
                Button {
                    triggerAIAnalysis()
                } label: {
                    HStack(spacing: 10) {
                        if isLoadingAnalysis {
                            ProgressView()
                                .tint(ThemePGM.deepPurple)
                        } else {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 18))
                        }
                        Text(isLoadingAnalysis ? "Analyzing..." : "AI Coach Analysis")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(ThemePGM.deepPurple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(ThemePGM.goldGradient)
                    .cornerRadius(16)
                }
                .disabled(isLoadingAnalysis)
                .interactiveButtonStylePGM()
            }

            if showAnalysis {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle().fill(ThemePGM.goldGradient).frame(width: 32, height: 32)
                            Image(systemName: "crown.fill").font(.system(size: 14)).foregroundColor(ThemePGM.deepPurple)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ProGM AI Coach").font(.system(size: 13, weight: .black)).foregroundStyle(ThemePGM.goldGradient)
                            Text("Article Analysis").font(.system(size: 10)).foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "sparkles")
                            .foregroundStyle(ThemePGM.goldGradient)
                    }

                    Text(LocalizedStringKey(aiAnalysis
                        .replacingOccurrences(of: "####", with: "**")
                        .replacingOccurrences(of: "###", with: "**")
                        .replacingOccurrences(of: "##", with: "**")
                        .replacingOccurrences(of: "#", with: "**")
                    ))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .background(ThemePGM.navyBlue.opacity(0.7))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ThemePGM.goldGradient.opacity(0.35), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.top, 16)
    }

    private func triggerAIAnalysis() {
        isLoadingAnalysis = true
        Task {
            if let aiResponse = await aiService.analyzeArticle(title: article.title, category: article.category, content: article.content) {
                await MainActor.run {
                    aiAnalysis = aiResponse
                    withAnimation(.spring()) { showAnalysis = true }
                    isLoadingAnalysis = false
                }
            } else {
                let fallback = await fallbackService.getArticleAnalysis(title: article.title, category: article.category)
                await MainActor.run {
                    aiAnalysis = fallback
                    withAnimation(.spring()) { showAnalysis = true }
                    isLoadingAnalysis = false
                }
            }
        }
    }

    private func takeawayRow(title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                .font(.system(size: 18))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    AcademyPGM()
        .environmentObject(ViewModelPGM())
}
