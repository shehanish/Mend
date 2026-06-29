//
//  ChatMessage.swift
//  Mend
//
//  Created by Shehani Hansika on 18.05.26.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
}
