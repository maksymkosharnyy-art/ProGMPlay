import Foundation

struct FallbackServicePGM {

    // MARK: - General Chat Fallbacks

    private let generalResponses: [String] = [
        "Control the center to dominate the game. Pawns on e4 and d4 give your pieces maximum scope and restrict your opponent's options. As **Steinitz** taught us, the player who controls the center controls the game.",
        "Develop your minor pieces before moving the queen. Every tempo spent on premature queen moves is a tempo your opponent uses to improve their position. **Morphy** demonstrated this principle beautifully in the Opera Game.",
        "A knight on the rim is dim, but a knight on an outpost is golden. Look for squares protected by your pawns where the knight can't be challenged by opponent pawns. **Nimzowitsch** considered outposts the foundation of positional play.",
        "Always look for forcing moves: checks, captures, and threats. Before settling on a quiet move, scan for tactical opportunities. Even **Karpov**, the master of positional chess, never missed a tactical shot.",
        "In the endgame, the king becomes a powerful attacking piece. Centralize it immediately when the position simplifies. A king on e5 or d5 can be worth almost as much as a minor piece in the endgame.",
        "Rooks belong on open files and the seventh rank. **Tarrasch** said the rook on the seventh rank is worth a pawn. Place your rooks where they can penetrate into your opponent's position.",
        "Don't push pawns in front of your castled king without a very good reason. Every pawn move creates weaknesses that can never be repaired. **Petrosian** built his entire defensive style around keeping the king's pawn shield intact.",
        "Calculate your opponent's best response before committing to a move. Ask yourself: 'If I play this, what is the strongest reply?' This habit separates improving players from stagnant ones.",
        "The bishop pair is a long-term advantage in open positions. If you have two bishops, try to open the position. If your opponent has the pair, keep it closed. **Fischer** was a master of exploiting the two bishops.",
        "Prophylaxis is the art of preventing your opponent's plans. Before making your move, ask: 'What does my opponent want to do next?' Then stop it. **Karpov** won more games by denying counterplay than by direct attacks.",
        "Study endgames first — they teach you the true value of pieces and pawns. **Capablanca** recommended starting with endgames because the board is clearer and the principles are more visible.",
        "When you're ahead in material, exchange pieces but not pawns. When you're behind, exchange pawns but not pieces. This principle helps convert advantages and create drawing chances respectively."
    ]

    // MARK: - Position Analysis Fallbacks

    private let positionAnalysisFallbacks: [String] = [
        "This is a critical moment in the position. The key factors to consider are: piece activity, king safety, and pawn structure. The best moves in chess always address the most important imbalance in the position.",
        "Interesting idea! When evaluating a candidate move, always consider three things: does it improve your worst piece, does it create or exploit a weakness, and does it maintain your king's safety? Apply this framework consistently.",
        "In positions like this, **pattern recognition** is crucial. Grandmasters don't calculate everything — they recognize familiar structures and know the typical plans. The more positions you study, the faster you'll see the right ideas.",
        "Good thinking! Remember that chess is about making the best practical decision with limited information. Even world champions don't find the perfect move every time. What matters is your **thinking process**, not just the result."
    ]

    // MARK: - Hint Fallbacks

    private let hintFallbacks: [String] = [
        "Look at the most vulnerable square in your opponent's position. Which piece can exploit it?",
        "Consider the activity of all your pieces. Is there one that isn't contributing? How can you activate it?",
        "Check for any undefended pieces in the opponent's camp. Loose pieces drop off!",
        "Think about the pawn structure. Is there a break or advance that opens lines for your pieces?",
        "What is your opponent's biggest threat? Sometimes the best move addresses their plan while improving yours.",
        "Look for checks and captures first. Forcing moves often reveal the solution."
    ]

    // MARK: - Move Feedback Fallbacks

    private let correctMoveFeedbacks: [String] = [
        "Excellent move! You found the key idea in this position. This kind of thinking — evaluating the position's demands and finding the move that addresses them — is what separates strong players from average ones. Keep training this instinct.",
        "Well done! That's exactly what a Grandmaster would play. You correctly identified the critical element of the position and responded precisely. Your tactical awareness is developing nicely.",
        "Perfect! You demonstrated strong **positional understanding** here. The ability to find the right move based on general principles rather than pure calculation shows real chess growth. Your accuracy is improving.",
        "Great find! This move shows you're starting to think like a strong player. You evaluated the imbalances correctly and found the most principled continuation. **Capablanca** would approve."
    ]

    private let incorrectMoveFeedbacks: [String] = [
        "Not quite — but your thinking is on the right track. The key issue is that your move doesn't address the most pressing concern in the position. Always ask: 'What is the position demanding right now?' The best moves solve the most critical problem first.",
        "Close, but there's a stronger continuation. In positions like this, look for **forcing moves** first. Checks, captures, and direct threats often reveal the winning idea before quieter alternatives.",
        "That move has some logic to it, but it misses a key tactical detail. Remember: before committing to any move, always check your opponent's best reply. This 'blunder check' is the most important habit in chess.",
        "Not the best here, but don't worry — mistakes are the best teachers. The crucial principle in this position is piece coordination. Ask yourself: are all my pieces working together toward the same goal?"
    ]

    // MARK: - Coaching Insight Fallbacks

    private let coachingInsights: [String] = [
        "Based on your training sessions, I recommend focusing on **tactical patterns**. Spend 15 minutes daily solving puzzles, starting with simple 1-move tactics and gradually increasing difficulty. Pattern recognition is the fastest path to improvement.",
        "Your positional play shows promise, but endgame technique needs attention. Study the **Lucena** and **Philidor** positions thoroughly — they appear in countless practical games. Once you master basic rook endgames, you'll convert many more advantages.",
        "Opening knowledge is solid, but middlegame planning could improve. Try this exercise: before each move, formulate a 3-move plan. Where do you want your pieces in 3 moves? This **strategic thinking habit** transforms your play.",
        "Your calculation ability is growing. To take it further, practice the **candidate moves** technique: identify 2-3 promising moves, then analyze each one systematically before choosing. Don't jump to the first attractive move."
    ]

    // MARK: - Article Analysis Fallbacks

    private let articleAnalysisByCategory: [String: [String]] = [
        "Openings": [
            "This article touches on one of the most fundamental aspects of chess: the opening phase. Understanding opening principles isn't about memorizing moves — it's about understanding **why** certain moves are played. Every opening aims to accomplish three things: control the center, develop pieces, and ensure king safety. Kasparov once said that studying openings teaches you the language of chess. Apply this by picking one opening as White and one as Black, and playing them exclusively for 50 games. You'll internalize the resulting middlegame plans naturally.",
            "Opening preparation separates serious players from casual ones. The key insight from this material is that **every move must have a purpose** in the opening. Don't move a piece twice unless you're winning material or avoiding a tactical threat. Bobby Fischer's opening play was revolutionary because he treated each opening move as part of a larger strategic plan. Try this: before your next game, spend 5 minutes reviewing the first 10 moves of your chosen opening and identify the key pawn breaks.",
        ],
        "Middlegame": [
            "The middlegame is where chess truly becomes art. This article highlights concepts that separate club players from masters: **piece coordination** and **plan formation**. Garry Kasparov emphasized that in the middlegame, you must always have a plan — even a wrong plan is better than no plan at all. The practical takeaway: before every move, ask yourself three questions. What is my opponent threatening? What do I want to achieve in 3-5 moves? Which of my pieces is worst placed, and how can I improve it?",
            "Middlegame mastery requires both calculation and intuition. The concepts in this article — whether about pawn structure, piece activity, or king safety — all revolve around one principle: **imbalances**. Jeremy Silman's teaching about evaluating imbalances (material, space, development, king safety, pawn structure) gives you a framework for every position. Practice this: after each game, identify the key imbalance that decided the outcome.",
        ],
        "Endgame": [
            "Endgame study is the fastest path to chess improvement, yet most players neglect it. As **Capablanca** taught, studying endgames reveals the true value of each piece. This article covers essential endgame knowledge that will save you countless half-points. The practical tip: master the Lucena and Philidor positions first. These two positions appear in roughly 8% of all games. Once you know them, you'll approach rook endgames with confidence instead of fear.",
            "The endgame is where games are won and lost at every level. This material emphasizes a truth that **Magnus Carlsen** exploits regularly: superior endgame technique creates winning chances from seemingly equal positions. The king becomes a powerful attacking piece once queens are off the board. Start practicing by playing endgame positions against a computer, focusing on technique rather than speed.",
        ],
        "GM Psychology": [
            "Chess is as much a psychological battle as an intellectual one. This article reveals the mental frameworks that Grandmasters use to perform under pressure. The most important insight is about **emotional regulation**: after a blunder, the strongest players reset their mental state within seconds. Petrosian's advice was to treat each position as a new puzzle, regardless of what happened before. Apply this by developing a pre-move ritual — take a breath, scan the board, then calculate.",
            "The psychological dimension of chess is often underestimated by improving players. This article highlights how champions like **Fischer** and **Kasparov** used mental toughness as a weapon. The practical takeaway is about time management: spend your thinking time on critical moments, not routine moves. Trust your intuition on obvious moves and save the clock for positions that demand deep calculation. This skill alone can add 100 rating points.",
        ],
    ]

    // MARK: - Game Analysis Fallbacks

    private let gameAnalysisFallbacks: [String] = [
        "This masterpiece demonstrates one of the most important principles in chess: the power of the **initiative**. When one player seizes control of the game's tempo, the opponent is forced into passive defense. Notice how the winning side consistently makes threats that demand responses, leaving no time for counterplay.\n\nThe key lesson here is about piece coordination. Every piece in the winning player's army works toward the same goal. Compare that to the losing side, where pieces are disjointed and lack harmony. In your own games, before making a move, ask yourself: are all my pieces contributing to the plan?\n\nStudy this game carefully and try to identify the **critical turning point** — the moment where one side's advantage became decisive. Understanding these inflection points is what separates strong players from beginners.",
        "What makes this game a true masterpiece is the perfect blend of **strategic planning** and **tactical execution**. The winner didn't just stumble upon brilliant moves — they created the conditions that made those moves possible through careful preparation.\n\nPay attention to how pawn structure shapes the entire game. The winning side used pawn breaks and pawn advances to open lines for their pieces, restrict the opponent's activity, and create lasting weaknesses. As **Philidor** said, 'Pawns are the soul of chess.' This game is a perfect illustration of that timeless truth.\n\nFor your own improvement, try replaying this game move by move and at each critical juncture, guess the next move before seeing it. This exercise — called **solitaire chess** — trains your pattern recognition and strategic intuition more effectively than any other method.",
        "This game showcases the devastating power of **sacrificial play** when backed by precise calculation. The winning side was willing to invest material — pieces or pawns — because they calculated that the resulting activity and initiative would be worth far more than the material deficit.\n\nThe crucial concept to take away is that chess is not about counting pieces — it's about evaluating the **dynamic balance** of the position. A player with fewer pieces can be winning if their remaining forces are far more active and coordinated. This is why development and piece activity are so fundamental.\n\nTo apply this in your games, practice evaluating positions not by material alone, but by asking: whose pieces are more active? Who controls more space? Whose king is safer? These questions will help you make better decisions at the board."
    ]

    // MARK: - Saved Position Fallbacks

    private let savedPositionFallbacks: [String] = [
        "This position presents an interesting strategic landscape. The key factors to evaluate are: **king safety** (are both kings adequately protected?), **piece activity** (which side has more active pieces?), and **pawn structure** (are there weaknesses to target or passed pawns to advance?).\n\nLook at the position through the lens of **imbalances** — the differences between the two sides that determine the character of the play. Material imbalances are obvious, but positional imbalances like space advantage, bishop pair, or better pawn structure often matter more in the long run.\n\nTo get the most from studying this position, try to formulate a plan for both sides. What would you play as White? As Black? This dual perspective will sharpen your strategic understanding enormously.",
        "Analyzing saved positions is one of the best habits for chess improvement. In this position, focus on three things: first, identify the **most active and least active pieces** on both sides. Second, determine where the play is happening — is it a kingside attack, queenside expansion, or central battle? Third, look for tactical motifs like pins, forks, skewers, or discovered attacks.\n\nThe position you saved likely caught your attention because something interesting was happening. Trust that instinct — your chess sense is developing. The fact that you're saving and reviewing positions shows the kind of dedication that leads to real improvement.\n\nTry setting up this position on a board and playing it out against yourself or a computer. Practical experience with a position teaches far more than passive analysis."
    ]

    // MARK: - Progress Analysis Fallbacks

    private let progressAnalysisFallbacks: [String] = [
        "Your chess journey is developing well. Every puzzle solved and every game played adds to your pattern library and strategic understanding. The key metrics show consistent engagement, which is the most important factor in chess improvement — **consistency beats intensity** every time.\n\nYour strongest areas show real promise. Building on strengths is just as important as fixing weaknesses, because strong areas give you confidence and practical winning chances. In tournament chess, players often win not by being well-rounded, but by steering games into positions where their strengths shine.\n\nFor improvement, I recommend a balanced training routine: spend 40% of your time on your weakest area with targeted exercises, 30% on solving tactical puzzles to maintain sharpness, 20% on studying master games (like the ones in your Library), and 10% on playing and analyzing your own games. Even 15-20 minutes daily with this structure will produce measurable results.\n\nSet a concrete short-term goal: solve 5 puzzles daily for the next 14 days without missing a day. Small, achievable goals build the discipline that eventually produces **breakthrough results**.",
        "Looking at your training data, I can see the foundation of a developing chess player. Your engagement with the app's various training modes — puzzles, articles, and games — shows the kind of well-rounded approach that produces lasting improvement.\n\nYour skill radar reveals important information about your chess profile. Every player has a unique pattern of strengths and weaknesses, and understanding yours is the first step toward targeted improvement. The areas where you score highest represent your natural chess tendencies — the types of positions you instinctively understand. Lean into these in competitive play.\n\nThe areas scoring lower aren't weaknesses to be ashamed of — they're **opportunities for rapid growth**. Because these skills are less developed, even small amounts of focused practice will produce visible improvement. I suggest dedicating specific training sessions to your lowest-scoring area: if it's tactics, solve 10 puzzles daily focused on that theme. If it's endgames, study one basic endgame position each day.\n\nRemember that chess improvement is not linear — it comes in **plateaus and breakthroughs**. If you feel stuck, that often means a breakthrough is imminent. Keep training, keep analyzing, and trust the process. The Grandmaster path is paved with daily dedication."
    ]

    // MARK: - Public Methods

    func getGameAnalysis(gameName: String, event: String) async -> String {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        return gameAnalysisFallbacks.randomElement() ?? gameAnalysisFallbacks[0]
    }

    func getSavedPositionAnalysis(title: String, notes: String) async -> String {
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        return savedPositionFallbacks.randomElement() ?? savedPositionFallbacks[0]
    }

    func getProgressAnalysis() async -> String {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        return progressAnalysisFallbacks.randomElement() ?? progressAnalysisFallbacks[0]
    }

    func getArticleAnalysis(title: String, category: String) async -> String {
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        let fallbacks = articleAnalysisByCategory[category] ?? articleAnalysisByCategory["Middlegame"]!
        return fallbacks.randomElement() ?? fallbacks[0]
    }

    func getRandomResponse() async -> String {
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        return generalResponses.randomElement() ?? generalResponses[0]
    }

    func getPositionAnalysis() async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return positionAnalysisFallbacks.randomElement() ?? positionAnalysisFallbacks[0]
    }

    func getHint() async -> String {
        try? await Task.sleep(nanoseconds: 800_000_000)
        return hintFallbacks.randomElement() ?? hintFallbacks[0]
    }

    func getMoveFeedback(isCorrect: Bool) async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        if isCorrect {
            return correctMoveFeedbacks.randomElement() ?? correctMoveFeedbacks[0]
        } else {
            return incorrectMoveFeedbacks.randomElement() ?? incorrectMoveFeedbacks[0]
        }
    }

    func getCoachingInsight() async -> String {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        return coachingInsights.randomElement() ?? coachingInsights[0]
    }

    func getOnboardingWelcome(level: String) async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        switch level {
        case "Beginner":
            return "Welcome to ProGM Play! As a beginner, your journey starts with the fundamentals — **piece development**, **center control**, and **king safety**. We'll build your chess intuition step by step with carefully selected positions. Let's begin your path to thinking like a Grandmaster!"
        case "Pro":
            return "Welcome, advanced player! Your training will focus on deep **positional understanding**, complex **tactical combinations**, and Grandmaster-level **endgame technique**. We'll challenge you with positions from world championship games. Time to sharpen your edge!"
        default:
            return "Welcome to ProGM Play! As an amateur player, you already know the basics — now it's time to develop real **strategic thinking**. We'll work on recognizing patterns, calculating variations, and understanding the 'why' behind every move. Your Grandmaster journey starts now!"
        }
    }
}
