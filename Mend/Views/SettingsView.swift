//
//  SettingsView.swift
//  Mend
//
//  Created by GitHub Copilot.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("dailyRemindersEnabled") private var dailyRemindersEnabled = true
    @AppStorage("healingHintsEnabled") private var healingHintsEnabled = true
    @AppStorage("reduceMotionEnabled") private var reduceMotionEnabled = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        header

                        settingsCard(title: "Healing") {
                            Toggle("Daily reminders", isOn: $dailyRemindersEnabled)
                            Toggle("Helpful hints", isOn: $healingHintsEnabled)
                            Toggle("Reduce motion", isOn: $reduceMotionEnabled)
                        }

                        settingsCard(title: "Account") {
                            Text("Use Profile to change your name or photo, and Log Out from the Home menu when you want to leave the app.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.brandPrimary)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Make Mend easier to use")
                .font(.title2.bold())
                .foregroundStyle(Color.brandPrimary)

            Text("Keep the parts that help most visible, and tone down what feels too much.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.brandPrimary)

            content()
                .font(.subheadline)
                .tint(Color.brandPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    SettingsView()
}