//
//  JournalViewModel.swift
//  Mend
//
//  Created by Shehani Hansika on 07.07.26.
//

import Foundation
import Observation
import SwiftData
import AVFoundation
import Speech

@MainActor
@Observable
final class JournalViewModel {
    private let context: ModelContext
    private let moodRepo: any MoodRepository
    private let userID: String
    private let userName: String

    var journalText: String = ""
    var gratitudeOne: String = ""
    var gratitudeTwo: String = ""
    var gratitudeThree: String = ""
    var transcriptText: String = ""
    var isRecording: Bool = false
    var isTranscribing: Bool = false
    var statusMessage: String?
    var moodEntries: [MoodEntry] = []
    var historyEntries: [JournalEntry] = []
    var timelineEntries: [TimelineEntry] = []
    var healingDashboard: HealingDashboard = .empty
    var debugHistoryMessage: String = "Debug: journal history not loaded yet"

    private var recorder: AVAudioRecorder?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recordingURL: URL?

    init(context: ModelContext, moodRepo: any MoodRepository, userID: String, userName: String) {
        self.context = context
        self.moodRepo = moodRepo
        self.userID = userID
        self.userName = userName
    }

    var displayName: String {
        userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Friend" : userName
    }

    var canSaveEntry: Bool {
        !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !transcriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !gratitudeOne.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !gratitudeTwo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !gratitudeThree.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func loadHistory() async {
        debugHistoryMessage = "Debug: loading history..."
        print("[JournalViewModel] loadHistory started for userID=\(userID)")

        do {
            let now = Date()
            let startOfWeek = Calendar.current.date(byAdding: .day, value: -6, to: now) ?? now
            moodEntries = try await moodRepo.fetchMoodEntries(userID: userID, from: startOfWeek, to: now)
                .sorted { $0.timestamp > $1.timestamp }

            let currentUserID = userID
            let predicate = #Predicate<JournalEntry> { entry in
                entry.userID == currentUserID
            }

            let descriptor = FetchDescriptor<JournalEntry>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )

            historyEntries = try context.fetch(descriptor)
            rebuildTimelineEntries()
            rebuildHealingDashboard()
            debugHistoryMessage = "Debug: loaded moods=\(moodEntries.count), journalEntries=\(historyEntries.count), timeline=\(timelineEntries.count)"
            print("[JournalViewModel] loadHistory success moods=\(moodEntries.count) journalEntries=\(historyEntries.count) timeline=\(timelineEntries.count)")
        } catch {
            statusMessage = "Could not load journal history."
            debugHistoryMessage = "Debug: loadHistory failed - \(error.localizedDescription)"
            print("[JournalViewModel] loadHistory failed: \(error)")
        }
    }

    func toggleRecording() async {
        if isRecording {
            await stopRecording()
        } else {
            await startRecording()
        }
    }

    func saveJournalEntry() {
        let trimmedJournal = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranscript = transcriptText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGratitudeOne = gratitudeOne.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGratitudeTwo = gratitudeTwo.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGratitudeThree = gratitudeThree.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedJournal.isEmpty || !trimmedTranscript.isEmpty || !trimmedGratitudeOne.isEmpty || !trimmedGratitudeTwo.isEmpty || !trimmedGratitudeThree.isEmpty else {
            statusMessage = "Add a journal, recording, or at least one gratitude before saving."
            debugHistoryMessage = "Debug: save blocked - no content to save"
            print("[JournalViewModel] saveJournalEntry blocked: empty content")
            return
        }

        debugHistoryMessage = "Debug: saving journal entry..."
        print("[JournalViewModel] saveJournalEntry started journal=\(!trimmedJournal.isEmpty) transcript=\(!trimmedTranscript.isEmpty) gratitudes=\(!trimmedGratitudeOne.isEmpty || !trimmedGratitudeTwo.isEmpty || !trimmedGratitudeThree.isEmpty)")

        let entry = JournalEntry(
            userID: userID,
            moods: nil,
            journalText: trimmedJournal,
            transcript: trimmedTranscript.isEmpty ? nil : trimmedTranscript,
            gratitudeOne: trimmedGratitudeOne,
            gratitudeTwo: trimmedGratitudeTwo,
            gratitudeThree: trimmedGratitudeThree
        )

        context.insert(entry)

        do {
            try context.save()
            historyEntries.insert(entry, at: 0)
            rebuildTimelineEntries()
            rebuildHealingDashboard()
            NotificationCenter.default.post(name: .journalEntriesDidChange, object: nil)
            journalText = ""
            gratitudeOne = ""
            gratitudeTwo = ""
            gratitudeThree = ""
            transcriptText = ""
            recordingURL = nil
            statusMessage = "Journal saved for today."
            debugHistoryMessage = "Debug: save succeeded, journalEntries=\(historyEntries.count), timeline=\(timelineEntries.count)"
            print("[JournalViewModel] saveJournalEntry success journalEntries=\(historyEntries.count) timeline=\(timelineEntries.count)")
        } catch {
            statusMessage = "Could not save your journal entry."
            debugHistoryMessage = "Debug: save failed - \(error.localizedDescription)"
            print("[JournalViewModel] saveJournalEntry failed: \(error)")
        }
    }

    func deleteMoodEntries(withKeys keys: Set<String>) async {
        guard !keys.isEmpty else { return }

        let targets = moodEntries.filter { keys.contains(moodEntryKey($0)) }
        guard !targets.isEmpty else { return }

        for entry in targets {
            context.delete(entry)
        }

        do {
            try context.save()
            NotificationCenter.default.post(name: .journalEntriesDidChange, object: nil)
            await loadHistory()
            statusMessage = "Mood entry deleted."
            print("[JournalViewModel] deleteMoodEntries success count=\(targets.count)")
        } catch {
            statusMessage = "Could not delete the mood entry."
            print("[JournalViewModel] deleteMoodEntries failed: \(error)")
        }
    }

    func deleteJournalEntries(withKeys keys: Set<String>) async {
        guard !keys.isEmpty else { return }

        let targets = historyEntries.filter { keys.contains(journalEntryKey($0)) }
        guard !targets.isEmpty else { return }

        for entry in targets {
            context.delete(entry)
        }

        do {
            try context.save()
            NotificationCenter.default.post(name: .journalEntriesDidChange, object: nil)
            await loadHistory()
            statusMessage = "Journal entry deleted."
            print("[JournalViewModel] deleteJournalEntries success count=\(targets.count)")
        } catch {
            statusMessage = "Could not delete the journal entry."
            print("[JournalViewModel] deleteJournalEntries failed: \(error)")
        }
    }

    private func startRecording() async {
        guard !isRecording else { return }

        let microphoneAllowed = await requestMicrophonePermission()
        guard microphoneAllowed else {
            statusMessage = "Microphone access is needed to record your journal."
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)

            let url = makeRecordingURL()
            let recorder = try AVAudioRecorder(url: url, settings: recordingSettings())
            recorder.record()

            self.recorder = recorder
            self.recordingURL = url
            self.isRecording = true
            self.statusMessage = "Recording started. Speak your journal entry."
        } catch {
            statusMessage = "Could not start recording."
            isRecording = false
        }
    }

    private func stopRecording() async {
        guard isRecording else { return }

        recorder?.stop()
        recorder = nil
        isRecording = false

        guard let recordingURL else {
            statusMessage = "Recording finished, but no audio file was found."
            return
        }

        statusMessage = "Transcribing your recording..."
        await transcribeAudio(at: recordingURL)
    }

    private func transcribeAudio(at url: URL) async {
        isTranscribing = true
        defer {
            isTranscribing = false
            recognitionTask = nil
        }

        let speechAllowed = await requestSpeechPermission()
        guard speechAllowed else {
            statusMessage = "Speech recognition permission is needed to create a transcript."
            return
        }

        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) else {
            statusMessage = "Transcript unavailable on this device."
            return
        }

        guard recognizer.isAvailable else {
            statusMessage = "Speech recognition is currently unavailable."
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false

        do {
            transcriptText = try await recognizeSpeech(recognizer: recognizer, request: request)
            statusMessage = transcriptText.isEmpty ? "Recording saved, but no transcript was captured." : "Transcript ready."
        } catch {
            statusMessage = "Could not create a transcript from the recording."
        }
    }

    private func recognizeSpeech(
        recognizer: SFSpeechRecognizer,
        request: SFSpeechURLRecognitionRequest
    ) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            recognitionTask = recognizer.recognitionTask(with: request) { result, error in
                if didResume {
                    return
                }

                if let error {
                    didResume = true
                    continuation.resume(throwing: error)
                    return
                }

                guard let result else { return }

                if result.isFinal {
                    didResume = true
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    private func makeRecordingURL() -> URL {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return folder.appendingPathComponent("journal-\(UUID().uuidString)").appendingPathExtension("m4a")
    }

    private func recordingSettings() -> [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }

    private func rebuildHealingDashboard() {
        let now = Date()
        let startOfWeek = Calendar.current.date(byAdding: .day, value: -6, to: now) ?? now
        let recentJournalEntries = historyEntries.filter { $0.timestamp >= startOfWeek && $0.timestamp <= now }
        let recentMoodEntries = moodEntries.filter { $0.timestamp >= startOfWeek && $0.timestamp <= now }
        let gratitudeDays = recentJournalEntries.filter {
            !$0.gratitudeOne.isEmpty || !$0.gratitudeTwo.isEmpty || !$0.gratitudeThree.isEmpty
        }.count

        let moodCounts = recentMoodEntries.flatMap(\.moods).reduce(into: [String: Int]()) { counts, mood in
            counts[mood, default: 0] += 1
        }

        let dominantMood = moodCounts.max(by: { $0.value < $1.value })?.key
        let supportiveMoodCount = countMoodMatches(in: moodCounts, moods: ["Calm", "Hopeful", "Okay"])
        let heavyMoodCount = countMoodMatches(in: moodCounts, moods: ["Anxious", "Sad", "Lonely", "Empty", "Angry", "Tired"])

        let moodTrend: String
        if recentMoodEntries.isEmpty {
            moodTrend = "Start a few check-ins and I’ll help you see patterns."
        } else if supportiveMoodCount > heavyMoodCount {
            moodTrend = "Your week is leaning steadier, with more supportive moods showing up."
        } else if heavyMoodCount > supportiveMoodCount {
            moodTrend = "This week has carried more heavy moments. Your notes suggest you’re still staying connected to yourself."
        } else {
            moodTrend = "Your week has felt mixed, which is normal. The key is that you kept checking in."
        }

        let themeSource = recentJournalEntries.flatMap { entry in
            [entry.journalText, entry.transcript ?? "", entry.moodNote ?? "", entry.gratitudeOne, entry.gratitudeTwo, entry.gratitudeThree]
        } + recentMoodEntries.flatMap { entry in
            [entry.notes ?? "", entry.moods.joined(separator: " ")]
        }
        let themes = extractThemes(from: themeSource)

        let supportMessage: String
        if heavyMoodCount > supportiveMoodCount {
            supportMessage = "Try one small grounding step today: breathe slowly, drink water, or reach out to someone safe."
        } else if gratitudeDays > 0 {
            supportMessage = "Keep noticing what helps. Gratitude and check-ins are building a clear picture of your healing."
        } else {
            supportMessage = "A few more entries will help the app show you what supports your healing most."
        }

        healingDashboard = HealingDashboard(
            weeklyCheckIns: recentMoodEntries.count,
            gratitudeDays: gratitudeDays,
            dominantMood: dominantMood,
            moodTrend: moodTrend,
            themes: themes,
            supportMessage: supportMessage
        )
    }

    private func rebuildTimelineEntries() {
        let moodItems = moodEntries.map { TimelineEntry.mood($0) }
        let journalItems = historyEntries.map { TimelineEntry.journal($0) }

        timelineEntries = (moodItems + journalItems).sorted { $0.timestamp > $1.timestamp }
    }

    private func countMoodMatches(in counts: [String: Int], moods: [String]) -> Int {
        moods.reduce(0) { total, mood in
            total + counts[mood, default: 0]
        }
    }

    private func extractThemes(from texts: [String]) -> [String] {
        let stopWords: Set<String> = [
            "the", "and", "for", "that", "this", "with", "from", "have", "has", "was", "were", "you",
            "your", "about", "today", "feel", "feeling", "just", "really", "very", "there", "they",
            "into", "been", "more", "some", "what", "when", "where", "will", "would", "could", "should"
        ]

        let words = texts
            .joined(separator: " ")
            .lowercased()
            .split { !$0.isLetter }
            .map(String.init)
            .filter { $0.count > 3 && !stopWords.contains($0) }

        let counts = words.reduce(into: [String: Int]()) { result, word in
            result[word, default: 0] += 1
        }

        return counts
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }

    func moodEntryKey(_ entry: MoodEntry) -> String {
        moodEntryKey(timestamp: entry.timestamp, moods: entry.moods, notes: entry.notes)
    }

    func journalEntryKey(_ entry: JournalEntry) -> String {
        journalEntryKey(
            timestamp: entry.timestamp,
            journalText: entry.journalText,
            transcript: entry.transcript,
            gratitudeOne: entry.gratitudeOne,
            gratitudeTwo: entry.gratitudeTwo,
            gratitudeThree: entry.gratitudeThree
        )
    }

    private func moodEntryKey(timestamp: Date, moods: [String], notes: String?) -> String {
        let moodsPart = moods.joined(separator: "|")
        let notesPart = notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return "\(timestamp.timeIntervalSince1970)-\(moodsPart)-\(notesPart)"
    }

    private func journalEntryKey(
        timestamp: Date,
        journalText: String,
        transcript: String?,
        gratitudeOne: String,
        gratitudeTwo: String,
        gratitudeThree: String
    ) -> String {
        let transcriptPart = transcript?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return [
            String(timestamp.timeIntervalSince1970),
            journalText.trimmingCharacters(in: .whitespacesAndNewlines),
            transcriptPart,
            gratitudeOne.trimmingCharacters(in: .whitespacesAndNewlines),
            gratitudeTwo.trimmingCharacters(in: .whitespacesAndNewlines),
            gratitudeThree.trimmingCharacters(in: .whitespacesAndNewlines)
        ].joined(separator: "-")
    }

    struct HealingDashboard {
        let weeklyCheckIns: Int
        let gratitudeDays: Int
        let dominantMood: String?
        let moodTrend: String
        let themes: [String]
        let supportMessage: String

        static let empty = HealingDashboard(
            weeklyCheckIns: 0,
            gratitudeDays: 0,
            dominantMood: nil,
            moodTrend: "Start a few check-ins and I’ll help you see patterns.",
            themes: [],
            supportMessage: "A few more entries will help the app show you what supports your healing most."
        )
    }

    struct TimelineEntry: Identifiable {
        enum Kind {
            case mood(MoodEntry)
            case journal(JournalEntry)
        }

        let id: String
        let timestamp: Date
        let kind: Kind

        static func mood(_ entry: MoodEntry) -> TimelineEntry {
            TimelineEntry(
                id: "mood-\(entry.timestamp.timeIntervalSince1970)-\(entry.moods.joined(separator: ","))",
                timestamp: entry.timestamp,
                kind: .mood(entry)
            )
        }

        static func journal(_ entry: JournalEntry) -> TimelineEntry {
            TimelineEntry(
                id: "journal-\(entry.timestamp.timeIntervalSince1970)-\(entry.journalText.hashValue)",
                timestamp: entry.timestamp,
                kind: .journal(entry)
            )
        }
    }
}

extension Notification.Name {
    static let journalEntriesDidChange = Notification.Name("journalEntriesDidChange")
}