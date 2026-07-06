//
//  OpenAIInsightService.swift
//  Mend
//
//  Created by Shehani Hansika on 12.05.26.
//


import Foundation

struct OpenAIInsightService: AIInsightService {
    let apiKey: String
    let model: String

    /// Recommended default model for cost-effective text generation.
    init(apiKey: String, model: String = "gpt-4o-mini") {
        self.apiKey = apiKey
        self.model = model
    }

    // MARK: - API Types

    private struct ChatCompletionsRequest: Encodable {
        struct Message: Encodable {
            let role: String   // "system" | "user"
            let content: String
        }

        let model: String
        let messages: [Message]
        let temperature: Double
    }

    private struct ChatCompletionsResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable {
                let role: String
                let content: String
            }
            let message: Message
        }

        let choices: [Choice]
    }

    // MARK: - Public API

    func generateMoodInsight(from input: MoodInsightInput, userName: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        let displayName = userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Friend" : userName
        let moodSummary = input.moodCounts
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
        let dominantMood = input.moodCounts.max { $0.value < $1.value }?.key ?? ""
        let moodGuidance = moodInsightGuidance(for: input.moodCounts)

        // Privacy-first: only aggregated counts and date range.
        let prompt = """
        Write MAXIMUM 3 very short, concise sentences about the user's check-in.
        Use only the moods provided below. Do NOT invent or switch to a different mood.
        Treat each mood literally and keep the response aligned to the exact mood label.
        Important: if the mood is Tired, describe low energy, fatigue, depletion, or a need to rest. Do NOT rewrite Tired as Calm, Okay, or peaceful.
        If the mood is Hopeful, reflect hope or encouragement. If the mood is Angry, reflect frustration or tension. If the mood is Sad, reflect sadness or heaviness.
        Please provide supportive and kind words acknowledging the actual mood data.
        Always include exactly one gentle, actionable suggestion they can do today based on their input.
        Do NOT diagnose, do NOT mention mental disorders, do NOT give medical instructions.
        Address the user naturally by name when it fits: \(displayName).

        Time range: \(iso8601(input.startDate)) to \(iso8601(input.endDate))
        Moods: \(moodSummary)
        Dominant mood: \(dominantMood)
        Mood guidance:
        \(moodGuidance)
        Personal notes: \(input.notes.joined(separator: "\\n"))

        If there is no data, encourage the user to log their mood.
        """

        let systemPrompt = """
        You are a compassionate mood reflection and healing AI assistant.
        Your ultimate goal is to help the user understand the mood data they just logged and support gentle healing.
        RULES:
        1. Only respond to the moods and notes provided in the prompt.
        2. Never introduce a mood, feeling, or problem that is not in the input.
        3. Follow the mood guidance exactly. Do not soften Tired into Calm, Okay, or peaceful unless those moods are also present.
        4. If the logged mood is hopeful, stay hopeful and encouraging.
        5. If the logged mood is mixed, reflect that gently without overexplaining.
        6. CRITICAL: Keep your response EXTREMELY brief. MAXIMUM 3 short sentences total. No long paragraphs.
        """

        let body = ChatCompletionsRequest(
            model: model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: prompt)
            ],
            temperature: 0.2
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            // Include response body for debugging (often contains useful error JSON).
            let bodyText = String(data: data, encoding: .utf8) ?? "<no response body>"
            throw NSError(
                domain: "OpenAIInsightService",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: bodyText]
            )
        }

        let decoded = try JSONDecoder().decode(ChatCompletionsResponse.self, from: data)
        let text = decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines)

        return text?.isEmpty == false ? text! : "No insight returned."
    }

    func generateChatResponse(conversation: [(isUser: Bool, text: String)], userName: String, context: ChatInsightContext?) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        let displayName = userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Friend" : userName
        let contextText = context?.isEmpty == false ? context!.promptText : "No additional home or journal context was provided."

        let systemPrompt = """
        You are a compassionate breakup recovery, mood reflection, and healing AI assistant.
        Your ultimate goal is to help the user feel understood and leave each reply with something useful they can do next.
        RULES:
        1. Use the conversation plus the supplied app context to tailor the reply.
        2. If the user’s recent mood or journal context is hopeful, steady, or mixed, reflect that accurately.
        3. If the context is heavy, be gentle and practical. Never invent a mood or problem that is not in the input.
        4. If the user mentions wanting to contact their ex, checking socials, or missing them, gently validate how hard it is but strictly encourage no contact.
        5. Never suggest reaching out to the ex, reconciling, or doing anything impulsive.
        6. Keep responses conversational, warm, and highly supportive.
        7. CRITICAL: Keep responses extremely brief and text-message length. 2-4 short sentences max.
        8. Always include one concrete next step or reflection question when it fits.
        9. Address the user naturally by name when it feels supportive: \(displayName).
        """

        var apiMessages: [ChatCompletionsRequest.Message] = [
            .init(role: "system", content: systemPrompt)
        ]

        apiMessages.append(.init(
            role: "user",
            content: "App context to use when relevant:\n\(contextText)"
        ))

        for msg in conversation {
            apiMessages.append(.init(role: msg.isUser ? "user" : "assistant", content: msg.text))
        }

        let body = ChatCompletionsRequest(
            model: model,
            messages: apiMessages,
            temperature: 0.35
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200...299).contains(http.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? "<no response body>"
            throw NSError(domain: "OpenAIInsightService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: bodyText])
        }

        let decoded = try JSONDecoder().decode(ChatCompletionsResponse.self, from: data)
        let text = decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return text?.isEmpty == false ? text! : "I'm here for you."
    }

    // MARK: - Helpers

    private func iso8601(_ date: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f.string(from: date)
    }

    private func moodInsightGuidance(for moodCounts: [String: Int]) -> String {
        let order = ["Angry", "Anxious", "Sad", "Tired", "Lonely", "Empty", "Okay", "Calm", "Hopeful"]
        let guidanceMap: [String: String] = [
            "Angry": "Angry means frustration, tension, or feeling upset.",
            "Anxious": "Anxious means worry, nervousness, or feeling on edge.",
            "Sad": "Sad means heaviness, grief, or low mood.",
            "Tired": "Tired means low energy, fatigue, depletion, or needing rest.",
            "Lonely": "Lonely means needing connection or feeling alone.",
            "Empty": "Empty means numbness, flatness, or feeling drained inside.",
            "Okay": "Okay means neutral, steady, or in-between.",
            "Calm": "Calm means settled, grounded, and at ease.",
            "Hopeful": "Hopeful means looking forward with some trust or encouragement."
        ]

        return order
            .filter { moodCounts[$0] != nil }
            .compactMap { mood in guidanceMap[mood].map { "\(mood): \($0)" } }
            .joined(separator: "\n")
    }
}
