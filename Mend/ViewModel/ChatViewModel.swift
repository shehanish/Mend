//
//  ChatViewModel.swift
//  Mend
//
//  Created by Shehani Hansika on 18.05.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = [
        ChatMessage(text: "I'm here to listen. What's on your mind?", isUser: false)
    ]
    var inputText: String = ""
    var isThinking: Bool = false
    
    private let aiService: any AIInsightService
    
    init(aiService: any AIInsightService) {
        self.aiService = aiService
    }
    
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // Add user message
        messages.append(ChatMessage(text: text, isUser: true))
        inputText = ""
        isThinking = true
        
        let conversation = messages.map { (isUser: $0.isUser, text: $0.text) }
        
        do {
            let response = try await aiService.generateChatResponse(conversation: conversation)
            messages.append(ChatMessage(text: response, isUser: false))
            isThinking = false
        } catch {
            messages.append(ChatMessage(text: "Something went wrong. Please try again.", isUser: false))
            isThinking = false
        }
    }
}
