//
//  ChatView.swift
//  Mend
//
//  Created by Shehani Hansika on 18.05.26.
//

import SwiftUI

struct ChatView: View {
    @State private var vm: ChatViewModel

    init(vm: ChatViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ZStack {
            // Match the background gradient from HomeView
            Color.appBackgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                Text("Chat area")
                    .font(.headline)
                    .foregroundStyle(Color.brandPrimary)
                    .padding()
                
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 16) {
                            ForEach(vm.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        // Auto-scroll to bottom when new messages arrive
                        .onChange(of: vm.messages.count) { _, _ in
                            if let last = vm.messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    Task {
                        await vm.sendPendingSeedMessageIfNeeded()
                    }
                }
                
                if vm.isThinking {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.92))
                                .overlay(
                                    Circle()
                                        .stroke(Color.brandPrimary.opacity(0.18), lineWidth: 1)
                                )
                                .frame(width: 42, height: 42)

                            BlobAvatarView(width: 22, height: 18, showShadow: false)
                                .frame(width: 42, height: 42, alignment: .center)
                                .offset(y: -1)
                        }
                     
                        
                        Text("typing...")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                }
                
                // Input Area
                HStack(alignment: .bottom, spacing: 10) {
                    TextField("Type how you feel...", text: $vm.inputText, axis: .vertical)
                        .padding(14)
                        .background(Color.white.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .environment(\.colorScheme, .light)
                        .lineLimit(1...5)
                        .autocorrectionDisabled()
                        .submitLabel(.send)
                        .onSubmit {
                            Task { await vm.sendMessage() }
                        }

                    Button(action: {
                        Task { await vm.sendMessage() }
                    }) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.brandPrimary.opacity(0.3)
                                : Color.brandPrimary
                            )
                            .clipShape(Circle())
                    }
                    .disabled(vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 15)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        dismissKeyboard()
                    }
                }
            }
        }
    }
}

#Preview {
    // Basic preview stub
    struct PreviewService: AIInsightService {
        func generateMoodInsight(from input: MoodInsightInput, userName: String) async throws -> String { "Stub" }
        func generateChatResponse(conversation: [(isUser: Bool, text: String)], userName: String, context: ChatInsightContext?) async throws -> String { "Stub reply" }
    }
    
    let vm = ChatViewModel(aiService: PreviewService(), userName: "Friend")
    return ChatView(vm: vm)
}
