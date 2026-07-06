//
//  HomeViewViewModel.swift
//  Mend
//
//  Created by Shehani Hansika on 11.05.26.
//


import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    //Text note user can type
    var notesText: String = ""
    //AI Strings
    var todayInsightText: String? = "You’re doing your best. Healing isn’t linear—take one small step today."
    var isGeneratingTodayInsight: Bool = false
    
    private let moodRepo: any MoodRepository
    private let aiService: any AIInsightService
    private let userID: String
    private let userName: String
    private let calendar: Calendar

    // Ephemeral UI state
    var selectedMoods: Set<String> = []

    // Weekly Home summary
    var weeklyMoodCounts: [MoodCount] = []
    var weeklyCheckInCount: Int = 0
    var weeklyNoteCount: Int = 0
    var weeklySummaryLine: String = "Add a few check-ins and I’ll show your weekly pattern here."
    var weeklyHelpfulPatternText: String = "Add a short note after a check-in and I can show what helped most."
    var weeklyWarningText: String?
    var weeklyTrendBars: [WeeklyTrendBar] = []
    var latestCheckInText: String = "No recent check-ins yet."

    

    // Error state (repo or AI)
    var lastError: String?

    init(
        moodRepo: any MoodRepository,
        aiService: any AIInsightService,
        userID: String,
        userName: String,
        calendar: Calendar = .current
    ) {
        self.moodRepo = moodRepo
        self.aiService = aiService
        self.userID = userID
        self.userName = userName
        self.calendar = calendar
    }

    // Derived UI state
    var canApply: Bool { true }


    // User action: save mood entry
    func apply() async {
        let applied = Array(selectedMoods).sorted()

        let trimmed = notesText.trimmingCharacters(in: .whitespacesAndNewlines)
        let notesOrNil: String? = trimmed.isEmpty ? nil : trimmed

        do {
            try await moodRepo.addMoodEntry(
                userID: userID,
                notes: notesOrNil,
                moods: applied,
                timestamp: .now
            )

            NotificationCenter.default.post(name: .journalEntriesDidChange, object: nil)

            selectedMoods.removeAll()
            notesText = ""
            lastError = nil

            await loadHomeSummary()
            await generateInsightForToday()
        } catch {
            print("[HomeViewModel] apply failed: \(error)")
            lastError = friendlyErrorMessage(for: error, fallback: "I couldn't save that check-in just now. Please try again.")
        }
    }

    func loadHomeSummary() async {
        do {
            let end = Date()
            let start = calendar.date(byAdding: .day, value: -6, to: end) ?? end
            let entries = try await moodRepo.fetchMoodEntries(userID: userID, from: start, to: end)

            let sortedEntries = entries.sorted { $0.timestamp < $1.timestamp }

            weeklyCheckInCount = sortedEntries.count
            weeklyNoteCount = sortedEntries.compactMap { entry in
                entry.notes?.trimmingCharacters(in: .whitespacesAndNewlines)
            }.filter { !$0.isEmpty }.count

            var counts: [String: Int] = [:]
            var moodScores: [Int] = []
            for entry in sortedEntries {
                for mood in entry.moods {
                    counts[mood, default: 0] += 1
                    moodScores.append(moodWeight(for: mood))
                }
            }

            weeklyMoodCounts = counts
                .map { MoodCount(mood: $0.key, count: $0.value) }
                .sorted { $0.count > $1.count }

            if let dominantMood = weeklyMoodCounts.first {
                weeklySummaryLine = "This week, \(dominantMood.mood) is showing up most often."
            } else {
                weeklySummaryLine = "Add a few check-ins and I’ll show your weekly pattern here."
            }

            weeklyHelpfulPatternText = helpfulPatternSummary(from: sortedEntries)
            weeklyWarningText = heavyWeekWarning(for: moodScores, checkInCount: sortedEntries.count)
            weeklyTrendBars = buildWeeklyTrendBars(from: sortedEntries, ending: end)

            if let latest = sortedEntries.last {
                let moodText = latest.moods.isEmpty ? "No mood selected" : latest.moods.joined(separator: ", ")
                let noteText = latest.notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                latestCheckInText = noteText.isEmpty ? moodText : "\(moodText) · \(noteText)"
            } else {
                latestCheckInText = "No recent check-ins yet."
            }
        } catch {
            print("[HomeViewModel] loadHomeSummary failed: \(error)")
            lastError = friendlyErrorMessage(for: error, fallback: "I couldn't load your home summary right now. Please try again.")
        }
    }

    private func buildWeeklyTrendBars(from entries: [MoodEntry], ending endDate: Date) -> [WeeklyTrendBar] {
        let weekStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate)

        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart),
                  let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else {
                return nil
            }

            let dayEntries = entries.filter { $0.timestamp >= day && $0.timestamp < nextDay }
            let moodScores = dayEntries.flatMap { $0.moods }.map(moodWeight(for:))
            let averageScore = moodScores.isEmpty ? 0.0 : Double(moodScores.reduce(0, +)) / Double(moodScores.count)

            return WeeklyTrendBar(
                dayLabel: shortDayLabel(for: day),
                averageScore: averageScore,
                entryCount: dayEntries.count
            )
        }
    }

    private func helpfulPatternSummary(from entries: [MoodEntry]) -> String {
        let noteText = entries.compactMap { entry in
            entry.notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }

        guard !noteText.isEmpty else {
            return "Add a short note after a check-in and I can show what helped most."
        }

        let themes: [(label: String, keywords: [String])] = [
            ("rest", ["rest", "sleep", "nap", "slow down"]),
            ("a walk", ["walk", "outside", "stretch", "move", "movement"]),
            ("breathing or meditation", ["breathe", "breathing", "meditation", "ground"]),
            ("talking to someone safe", ["talk", "text", "friend", "support", "call"]),
            ("writing it down", ["journal", "write", "writing", "note"]),
            ("food and water", ["water", "drink", "eat", "meal", "food"]),
            ("music", ["music", "song", "playlist"]),
            ("therapy", ["therapy", "therapist", "counselor", "counsellor"])
        ]

        var counts: [String: Int] = [:]
        for note in noteText {
            let lowercased = note.lowercased()
            for theme in themes where theme.keywords.contains(where: { lowercased.contains($0) }) {
                counts[theme.label, default: 0] += 1
            }
        }

        let topThemes = counts
            .sorted { $0.value > $1.value }
            .prefix(2)
            .map { $0.key }

        guard !topThemes.isEmpty else {
            return "You’ve been writing things down consistently. That itself is helping you notice patterns."
        }

        return "What helped most: \(topThemes.joined(separator: " and "))."
    }

    private func heavyWeekWarning(for scores: [Int], checkInCount: Int) -> String? {
        guard checkInCount >= 3, !scores.isEmpty else {
            return nil
        }

        let averageScore = Double(scores.reduce(0, +)) / Double(scores.count)

        if averageScore <= -0.35 {
            return "This week looks heavy. Keep the next step very small and gentle."
        } else if averageScore <= -0.15 {
            return "Some of this week has felt heavy. Small steps still count."
        } else {
            return nil
        }
    }

    private func moodWeight(for mood: String) -> Int {
        switch mood.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "calm", "hopeful":
            return 1
        case "okay":
            return 0
        case "sad", "angry", "anxious", "lonely", "empty", "tired":
            return -1
        default:
            return 0
        }
    }

    private func shortDayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .current
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    /// Generates a 1–3 sentence insight based only on mood entries logged today.
    func generateInsightForToday() async {
        guard !isGeneratingTodayInsight else { return }

        isGeneratingTodayInsight = true
        todayInsightText = "I’m here with you… just a moment."   // show text immediately
        lastError = nil

        // Artificial pause so the user sees the loading state
        try? await Task.sleep(nanoseconds: 700_000_000) // 0.7s

        defer { isGeneratingTodayInsight = false }

        do {
            let now = Date()
            let startOfToday = calendar.startOfDay(for: now)

            let entries = try await moodRepo.fetchMoodEntries(
                userID: userID,
                from: startOfToday,
                to: now
            )

            var counts: [String: Int] = [:]
            var allNotes: [String] = []
            for entry in entries {
                for mood in entry.moods {
                    counts[mood, default: 0] += 1
                }
                if let note = entry.notes, !note.isEmpty {
                    allNotes.append(note)
                }
            }

            // If no moods logged today, keep a general supportive message (no AI call)
            guard !counts.isEmpty || !allNotes.isEmpty else {
                todayInsightText = "If today feels heavy, try one gentle thing: water, a walk, or texting someone safe."
                return
            }

            let input = MoodInsightInput(
                startDate: startOfToday,
                endDate: now,
                moodCounts: counts,
                notes: allNotes
            )

            todayInsightText = try await aiService.generateMoodInsight(from: input, userName: userName)
        } catch {
            print("[HomeViewModel] generateInsightForToday failed: \(error)")
            lastError = friendlyErrorMessage(for: error, fallback: "I couldn't generate your reflection right now. Please try again.")
            todayInsightText = "Something went wrong generating your reflection. Try again in a moment."
        }
    }

    private func friendlyErrorMessage(for error: Error, fallback: String) -> String {
        let nsError = error as NSError

        if nsError.domain == NSURLErrorDomain || nsError.domain == NSCocoaErrorDomain {
            return fallback
        }

        return fallback
    }
}

struct WeeklyTrendBar: Identifiable, Hashable {
    let dayLabel: String
    let averageScore: Double
    let entryCount: Int

    var id: String { dayLabel }

    var normalizedHeight: Double {
        let normalized = (averageScore + 1.0) / 2.0
        return max(0.12, min(1.0, normalized))
    }
}
