import SwiftUI

struct ProgressPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM

    @State private var aiProgressReport: String = ""
    @State private var isAnalyzing: Bool = false

    var stats: [(String, String, String)] {
        [
            ("Puzzles Solved", "\(viewModel.totalPuzzlesSolved)", "puzzlepiece.fill"),
            ("Avg. Accuracy", "\(viewModel.logicAccuracy)%", "brain.head.profile"),
            ("Games Played", "\(viewModel.gamesPlayed)", "bolt.fill"),
            ("Win Rate", "\(viewModel.winRate)%", "chart.bar.fill"),
            ("Articles Read", "\(viewModel.articlesRead)", "book.fill"),
            ("Current Streak", "\(viewModel.currentStreak)d", "flame.fill")
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                progressHeader
                
                levelBadge
                
                masteryAssessment
                
                statsGrid
                
                aiCoachSection
                
                successTimeline
                
                milestoneTracker
                
                trophyRoom
                
                Spacer(minLength: 120)
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .background(ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea())
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("My Path")
                        .font(.title.weight(.black))
                        .foregroundColor(.white)

                    Text("Track your journey to Grandmaster")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()

                Image("progress_hero")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(ThemePGM.goldGradient, lineWidth: 2)
                    )
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Level Badge

    private var levelBadge: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: levelIcon)
                    .font(.title2)
                    .foregroundStyle(ThemePGM.goldGradient)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Current Level")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(viewModel.userChessLevel)
                    .font(.title2.weight(.black))
                    .foregroundColor(.white)

                Text(levelDescription)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }

            Spacer()

            VStack(spacing: 4) {
                Text("\(overallScore)")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(ThemePGM.goldGradient)

                Text("Score")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var levelIcon: String {
        switch viewModel.userChessLevel {
        case "Beginner": return "star.fill"
        case "Pro": return "crown.fill"
        default: return "shield.checkered"
        }
    }

    private var levelDescription: String {
        switch viewModel.userChessLevel {
        case "Beginner": return "Building fundamentals and tactical awareness"
        case "Pro": return "Advanced strategic and positional mastery"
        default: return "Developing pattern recognition and strategy"
        }
    }

    private var overallScore: Int {
        let p = viewModel.userProgress
        let avg = (p.tacticalVigilance + p.strategy + p.responseSpeed + p.positionalUnderstanding + p.openings) / 5.0
        return Int(avg * 100)
    }

    // MARK: - Mastery Assessment

    private var masteryAssessment: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "hexagon.fill")
                        .foregroundStyle(ThemePGM.goldGradient)
                    Text("Skill Radar")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text(viewModel.userChessLevel)
                    .font(.caption.weight(.bold))
                    .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.15))
                    .clipShape(Capsule())
            }

            RadarChartPGM(values: viewModel.userProgress.radarValues)
                .frame(height: 260)

            skillBreakdown
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var skillBreakdown: some View {
        let skills: [(String, Double, String)] = [
            ("Tactics", viewModel.userProgress.tacticalVigilance, "target"),
            ("Strategy", viewModel.userProgress.strategy, "square.grid.3x3"),
            ("Speed", viewModel.userProgress.responseSpeed, "timer"),
            ("Endgame", viewModel.userProgress.positionalUnderstanding, "crown.fill"),
            ("Openings", viewModel.userProgress.openings, "book.closed.fill")
        ]

        return VStack(spacing: 8) {
            ForEach(skills, id: \.0) { skill in
                HStack(spacing: 10) {
                    Image(systemName: skill.2)
                        .font(.caption)
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        .frame(width: 20)

                    Text(skill.0)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white)
                        .frame(width: 60, alignment: .leading)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(ThemePGM.goldGradient)
                                .frame(width: geo.size.width * CGFloat(skill.1), height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("\(Int(skill.1 * 100))%")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        .frame(width: 36, alignment: .trailing)
                }
            }
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(stats, id: \.0) { stat in
                VStack(spacing: 10) {
                    Image(systemName: stat.2)
                        .font(.title2)
                        .foregroundStyle(ThemePGM.goldGradient)

                    Text(stat.1)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)

                    Text(stat.0)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - AI Coach Section

    private var aiCoachSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(ThemePGM.goldGradient)
                Text("GM Coach Report")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
            }

            Button {
                triggerProgressAnalysis()
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text(aiProgressReport.isEmpty ? "Generate Progress Analysis" : "Regenerate Report")
                        .font(.headline.weight(.bold))
                }
                .foregroundColor(ThemePGM.deepPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ThemePGM.goldGradient)
                .cornerRadius(14)
            }
            .disabled(isAnalyzing)
            .opacity(isAnalyzing ? 0.6 : 1.0)

            if isAnalyzing {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    Text("Your GM Coach is reviewing your progress...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }

            if !aiProgressReport.isEmpty {
                Text(LocalizedStringKey(aiProgressReport
                    .replacingOccurrences(of: "####", with: "**")
                    .replacingOccurrences(of: "###", with: "**")
                    .replacingOccurrences(of: "##", with: "**")
                    .replacingOccurrences(of: "#", with: "**")
                ))
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(5)
                .padding()
                .background(ThemePGM.navyBlue.opacity(0.5))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func triggerProgressAnalysis() {
        isAnalyzing = true
        aiProgressReport = ""

        Task { @MainActor in
            if let result = await viewModel.aiService.analyzeUserProgress(context: viewModel.userContext) {
                aiProgressReport = result
            } else {
                let fallback = await viewModel.fallbackService.getProgressAnalysis()
                aiProgressReport = fallback
            }
            isAnalyzing = false
        }
    }

    // MARK: - Success Timeline

    private var successTimeline: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(ThemePGM.goldGradient)
                Text("Weekly Progress")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
            }

            Text("Your activity over the past 7 days")
                .font(.caption)
                .foregroundColor(.gray)

            WeeklyChartPGM(weekData: viewModel.weeklyActivityValues)
                .frame(height: 160)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This Week")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("\(viewModel.logicAccuracy)%")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(ThemePGM.goldGradient)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Streak")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("\(viewModel.currentStreak) days")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Milestone Tracker

    private var milestoneTracker: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "flag.fill")
                    .foregroundStyle(ThemePGM.goldGradient)
                Text("Milestones")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
            }

            let milestones: [(String, Int, Int, String)] = [
                ("Puzzles Solved", viewModel.totalPuzzlesSolved, 50, "puzzlepiece.fill"),
                ("Articles Read", viewModel.articlesRead, 10, "book.fill"),
                ("Games Played", viewModel.gamesPlayed, 20, "bolt.fill"),
                ("Day Streak", viewModel.currentStreak, 30, "flame.fill")
            ]

            ForEach(milestones, id: \.0) { milestone in
                HStack(spacing: 12) {
                    Image(systemName: milestone.3)
                        .font(.caption)
                        .foregroundStyle(ThemePGM.goldGradient)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(milestone.0)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(milestone.1)/\(milestone.2)")
                                .font(.caption.weight(.bold))
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 6)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(ThemePGM.goldGradient)
                                    .frame(
                                        width: geo.size.width * min(1.0, CGFloat(milestone.1) / CGFloat(milestone.2)),
                                        height: 6
                                    )
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Trophy Room

    private var trophyRoom: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(ThemePGM.goldGradient)
                    Text("Trophy Room")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                }

                Spacer()

                let unlocked = viewModel.achievements.filter { $0.isUnlocked }.count
                Text("\(unlocked)/\(viewModel.achievements.count)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ThemePGM.goldGradient)
            }

            Text("Earn trophies by solving puzzles, reading articles, winning matches, and maintaining streaks.")
                .font(.caption)
                .foregroundColor(.gray)
                .lineSpacing(2)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(viewModel.achievements) { achievement in
                    TrophyCardPGM(achievement: achievement)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Trophy Card

struct TrophyCardPGM: View {
    let achievement: AchievementPGM

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                            ? AnyShapeStyle(ThemePGM.goldGradient)
                            : AnyShapeStyle(Color.white.opacity(0.08))
                    )
                    .frame(width: 56, height: 56)

                if achievement.isUnlocked {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 56, height: 56)
                }

                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundColor(achievement.isUnlocked ? ThemePGM.deepPurple : .gray.opacity(0.5))
            }

            Text(achievement.title)
                .font(.caption2.weight(.bold))
                .foregroundColor(achievement.isUnlocked ? .white : .gray)
                .lineLimit(1)

            Text(achievement.description)
                .font(.caption2)
                .foregroundColor(.gray.opacity(0.7))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 90)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Weekly Chart

struct WeeklyChartPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let weekData: [CGFloat]

    var dayLabels: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            return formatter.string(from: date)
        }
    }

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<min(7, weekData.count), id: \.self) { index in
                    let value = weekData[index]
                    let isToday = index == weekData.count - 1
                    VStack(spacing: 6) {
                        Spacer()

                        Text("\(Int(value * 100))%")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(isToday ? ThemePGM.accentColor(for: viewModel.selectedTheme) : .gray)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                isToday
                                    ? AnyShapeStyle(ThemePGM.goldGradient)
                                    : value > 0
                                        ? AnyShapeStyle(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.4))
                                        : AnyShapeStyle(Color.white.opacity(0.08))
                            )
                            .frame(
                                width: max(20, (geo.size.width - 80) / 7),
                                height: value > 0 ? max(10, geo.size.height * 0.6 * value) : 4
                            )

                        Text(index < dayLabels.count ? dayLabels[index] : "")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(isToday ? ThemePGM.accentColor(for: viewModel.selectedTheme) : .gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Radar Chart

struct RadarChartPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let categories = UserProgressPGM.radarLabels
    var values: [CGFloat] = [0.8, 0.6, 0.9, 0.5, 0.7]

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let maxRadius = min(geometry.size.width, geometry.size.height) / 2 * 0.7

            ZStack {
                ForEach(1...5, id: \.self) { step in
                    Path { path in
                        let r = maxRadius * CGFloat(step) / 5
                        for index in 0..<5 {
                            let angle = CGFloat(index) * 2 * .pi / 5 - .pi / 2
                            let point = CGPoint(
                                x: center.x + r * cos(angle),
                                y: center.y + r * sin(angle)
                            )
                            if index == 0 { path.move(to: point) }
                            else { path.addLine(to: point) }
                        }
                        path.closeSubpath()
                    }
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                }

                ForEach(0..<5, id: \.self) { index in
                    let angle = CGFloat(index) * 2 * .pi / 5 - .pi / 2
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: CGPoint(
                            x: center.x + maxRadius * cos(angle),
                            y: center.y + maxRadius * sin(angle)
                        ))
                    }
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                }

                Path { path in
                    for index in 0..<5 {
                        let angle = CGFloat(index) * 2 * .pi / 5 - .pi / 2
                        let pointRadius = maxRadius * values[index]
                        let point = CGPoint(
                            x: center.x + pointRadius * cos(angle),
                            y: center.y + pointRadius * sin(angle)
                        )
                        if index == 0 { path.move(to: point) }
                        else { path.addLine(to: point) }
                    }
                    path.closeSubpath()
                }
                .fill(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.2))

                Path { path in
                    for index in 0..<5 {
                        let angle = CGFloat(index) * 2 * .pi / 5 - .pi / 2
                        let pointRadius = maxRadius * values[index]
                        let point = CGPoint(
                            x: center.x + pointRadius * cos(angle),
                            y: center.y + pointRadius * sin(angle)
                        )
                        if index == 0 { path.move(to: point) }
                        else { path.addLine(to: point) }
                    }
                    path.closeSubpath()
                }
                .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme), lineWidth: 2)

                ForEach(0..<5, id: \.self) { index in
                    let angle = CGFloat(index) * 2 * .pi / 5 - .pi / 2
                    let pointRadius = maxRadius * values[index]
                    Circle()
                        .fill(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        .frame(width: 8, height: 8)
                        .position(
                            x: center.x + pointRadius * cos(angle),
                            y: center.y + pointRadius * sin(angle)
                        )
                }

                ForEach(0..<5, id: \.self) { index in
                    let angle = CGFloat(index) * 2 * .pi / 5 - .pi / 2
                    let labelRadius = maxRadius * 1.3
                    VStack(spacing: 2) {
                        Text(categories[index])
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)

                        Text("\(Int(values[index] * 100))%")
                            .font(.caption2)
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    }
                    .position(
                        x: center.x + labelRadius * cos(angle),
                        y: center.y + labelRadius * sin(angle)
                    )
                }
            }
        }
    }
}

#Preview {
    ProgressPGM()
        .environmentObject(ViewModelPGM())
        .background(ThemePGM.deepPurple.ignoresSafeArea())
}
