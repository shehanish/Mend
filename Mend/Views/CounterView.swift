//
//  CounterView.swift
//  Mend
//
//  Created by Shehani Hansika on 07.05.26.
//

import SwiftUI
import Combine

struct CounterView: View {
    @State private var isTrackerActive = false
    @State private var showSetupSheet = false
    
    // Details for tracker
    @State private var selectedDate: Date = .now
    @State private var selectedPeriod: String?

    var body: some View {
        ZStack {
            Color.appBackgroundGradient
                .ignoresSafeArea()

            if isTrackerActive {
                ActiveTrackerView(startDate: selectedDate, goal: selectedPeriod) {
                    isTrackerActive = false
                    selectedPeriod = nil
                }
            } else {
                // Initial State
                VStack(spacing: 30) {
                    Image("bubu") // Placeholder for illustration if needed
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    
                    Text("Ready to take a step back?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textOnPrimary)
                    
                    Text("Starting no contact gives you space to heal and refocus on yourself.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.textOnPrimary.opacity(0.8))
                        .padding(.horizontal, 30)

                    Button(action: {
                        showSetupSheet = true
                    }) {
                        Text("Start Go For No Contact")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brandPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
            }
        }
        .sheet(isPresented: $showSetupSheet) {
            NoContactSetupSheet(
                selectedDate: $selectedDate,
                selectedPeriod: $selectedPeriod,
                onSave: {
                    isTrackerActive = true
                    showSetupSheet = false
                }
            )
            .presentationDetents([.fraction(0.6), .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    CounterView()
}
