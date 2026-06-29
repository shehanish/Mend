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

    func generateMoodInsight(from input: MoodInsightInput) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        // Privacy-first: only aggregated counts and date range.
        let prompt = """
        Write MAXIMUM 3 very short, concise sentences about today's check-in. The user logged the following moods and personal notes.
        Please provide supportive and kind words acknowledging how they feel. 
        Always include exactly one gentle, actionable suggestion they can do today based on their input.
        Do NOT diagnose, do NOT mention mental disorders, do NOT give medical instructions.

        Time range: \(iso8601(input.startDate)) to \(iso8601(input.endDate))
        Mood counts: \(input.moodCounts)
        Personal notes: \(input.notes.joined(separator: "\\n"))

        If there is no data, encourage the user to log their mood.
        """

        let systemPrompt = """
        You are a compassionate breakup recovery and healing AI assistant.
        Your ultimate goal is to help the user heal, maintain boundaries, and move on from their breakup.
        RULES:
        1. If the user mentions wanting to contact their ex, checking their socials, or missing them, gently validate how hard it is but STRICTLY encourage them to maintain "no contact" for their own peace.
        2. NEVER suggest reaching out to the ex, reconciling, or doing anything impulsive/unnecessary. 
        3. Shift their focus back onto self-love, self-care, and moving forward.
        4. CRITICAL: Keep your response EXTREMELY brief. MAXIMUM 3 short sentences total. No long paragraphs.
        """

        let body = ChatCompletionsRequest(
            model: model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: prompt)
            ],
            temperature: 0.6
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

    func generateChatResponse(conversation: [(isUser: Bool, text: String)]) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        let systemPrompt = """
        You are a compassionate breakup recovery and healing AI assistant.
        Your ultimate goal is to help the user heal, maintain boundaries, and move on from their breakup in a conversational format.
        RULES:
        1. If the user mentions wanting to contact their ex, checking their socials, or missing them, gently validate how hard it is but STRICTLY encourage them to maintain "no contact" for their own peace.
        2. NEVER suggest reaching out to the ex, reconciling, or doing anything impulsive/unnecessary. 
        3. Shift their focus back onto self-love, self-care, and moving forward.
        4. Keep your response conversational, warm, and highly supportive. Be a good listener.
        5. CRITICAL: Keep responses extremely brief and text-message length. 2-3 short sentences max.
        """

        var apiMessages: [ChatCompletionsRequest.Message] = [
            .init(role: "system", content: systemPrompt)
        ]

        for msg in conversation {
            apiMessages.append(.init(role: msg.isUser ? "user" : "assistant", content: msg.text))
        }

        let body = ChatCompletionsRequest(
            model: model,
            messages: apiMessages,
            temperature: 0.7
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
}
