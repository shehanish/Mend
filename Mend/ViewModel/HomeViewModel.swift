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
    private let calendar: Calendar

    // Ephemeral UI state
    var selectedMoods: Set<String> = []

    

    // Error state (repo or AI)
    var lastError: String?

    init(
        moodRepo: any MoodRepository,
        aiService: any AIInsightService,
        userID: String,
        calendar: Calendar = .current
    ) {
        self.moodRepo = moodRepo
        self.aiService = aiService
        self.userID = userID
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

            selectedMoods.removeAll()
            notesText = ""
            lastError = nil

            await generateInsightForToday()
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Generates a 1–3 sentence insight based only on mood entries logged today.
    func generateInsightForToday() async {
        guard !isGeneratingTodayInsight else { return }

        isGeneratingTodayInsight = true
        todayInsightText = "Thinking…"   // show text immediately
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

            todayInsightText = try await aiService.generateMoodInsight(from: input)
        } catch {
            lastError = String(describing: error)
            todayInsightText = "Something went wrong generating your reflection. Try again in a moment."
        }
    }
}
