//
//  MoodsSectionView.swift
//  Mend
//
//  Created by Shehani Hansika on 07.05.26.
//


import SwiftUI

struct MoodsSectionView: View {
    let moods: [String]
    @Binding var selectedMoods: Set<String>

    // NEW: bind the note text
    @Binding var notesText: String

    var onApply: (_ appliedMoods: [String]) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How are you feeling?")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .foregroundStyle(Color.brandPrimary)

            MoodPicker(moods: moods, selectedMoods: $selectedMoods)

            VStack(spacing: 12) {
                SelectedMoodsBox(selectedMoods: Array(selectedMoods).sorted())
                    .frame(maxWidth: 420)
                    .frame(maxWidth: .infinity, alignment: .center)

                // NEW: Note box under selected moods box
                VStack(alignment: .leading, spacing: 8) {
                    Text("Would you like to tell me a bit more about how you're feeling?")
                        .font(.subheadline)
                        .foregroundStyle(Color.brandPrimary)

                    TextField("Type how you feel in words…", text: $notesText, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(12)
                        .background(.white.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .environment(\.colorScheme, .light)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.brandPrimary.opacity(0.35), lineWidth: 1)
                        )
                }

                Button {
                    onApply(Array(selectedMoods).sorted())
                } label: {
                    Text("Apply")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.darkCharcoal)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                
            }
            .padding(.horizontal)
        }
    }
}
#Preview {
    MoodsSectionViewPreviewWrapper()
}

private struct MoodsSectionViewPreviewWrapper: View {
    private let moods = [
        "Calm", "Sad", "Angry", "Anxious",
        "Okay", "Hopeful", "Tired", "Lonely", "Empty"
    ]

    @State private var selectedMoods: Set<String> = ["Calm", "Tired"]
    @State private var notesText: String = "I felt a bit overwhelmed today, but better now."

    var body: some View {
        MoodsSectionView(
            moods: moods,
            selectedMoods: $selectedMoods,
            notesText: $notesText
        ) { _ in
            // Action for preview
        }
        .padding()
    }
}
