//
//  MoodPicker.swift
//  Mend
//
//  Created by Shehani Hansika on 07.05.26.
//

import SwiftUI

struct MoodPicker: View {
    let moods: [String]
    @Binding var selectedMoods: Set<String>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(moods, id: \.self) { mood in
                    MoodChip(
                        title: mood,
                        isSelected: selectedMoods.contains(mood)
                    ) {
                        toggle(mood)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }

    private func toggle(_ mood: String) {
        withAnimation(.snappy) {
            if selectedMoods.contains(mood) {
                selectedMoods.remove(mood)
            } else {
                selectedMoods.insert(mood)
            }
        }
    }
}

private struct MoodChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.subheadline)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .foregroundStyle(Color.brandPrimary)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.sageGreen.opacity(0.3) : Color.white.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color.sageGreen.opacity(0.5) : Color.sageGreen.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MoodPicker(moods: ["Calm", "Sad", "Angry", "Anxious", "Okay", "Hopeful", "Tired", "Lonely"], selectedMoods: .constant(["Calm", "Sad"]))
}

