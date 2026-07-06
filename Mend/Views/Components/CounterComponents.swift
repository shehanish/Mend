import SwiftUI
import Combine

struct NoContactSetupSheet: View {
    @Binding var selectedDate: Date
    @Binding var selectedPeriod: String?
    var onSave: () -> Void
    
    @State private var customDays: String = ""
    
    private let periodOptions = [
        "30 Days",
        "60 Days",
        "90 Days",
        "Unlimited / Not Decided",
        "Custom"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        Text("Set Up No Contact")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textOnPrimary)
                            .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("When did you start?")
                                .font(.subheadline)
                                .foregroundStyle(Color.textOnPrimary.opacity(0.8))
                                .padding(.horizontal, 20)

                            DatePicker(
                                "Start Date & Time",
                                selection: $selectedDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .padding()
                            .background(.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                        }

                        DropDownView(
                            title: "How long is your goal?",
                            prompt: "Select duration",
                            options: periodOptions,
                            selection: $selectedPeriod
                        )
                        .padding(.top, 10)

                        if selectedPeriod == "Custom" {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Enter number of days")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.textOnPrimary.opacity(0.8))
                                    .padding(.horizontal, 20)

                                TextField("e.g. 14", text: $customDays)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(.white.opacity(0.8))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .environment(\.colorScheme, .light)
                                    .padding(.horizontal)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Spacer(minLength: 30)

                        Button(action: {
                            if selectedPeriod == "Custom" && !customDays.isEmpty {
                                selectedPeriod = "\(customDays) Days"
                            }
                            onSave()
                        }) {
                            Text("Save and Start")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background((selectedPeriod != nil && (selectedPeriod != "Custom" || !customDays.isEmpty)) ? Color.brandPrimary : Color.brandPrimary.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(selectedPeriod == nil || (selectedPeriod == "Custom" && customDays.isEmpty))
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                    }
                    .animation(.snappy, value: selectedPeriod)
                }
                .scrollDismissesKeyboard(.interactively)
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

// MARK: - Active Tracker View
struct ActiveTrackerView: View {
    let startDate: Date
    let goal: String?
    let onReset: () -> Void
    
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var goalDays: Double? {
        guard let goal = goal else { return nil }
        if goal.contains("Unlimited") || goal.contains("Not Decided") {
            return nil
        }
        let daysString = goal.replacingOccurrences(of: " Days", with: "").trimmingCharacters(in: .whitespaces)
        return Double(daysString)
    }
    
    private var progress: Double {
        guard let goalDays = goalDays, goalDays > 0 else { return 1.0 }
        let totalSeconds = goalDays * 24 * 60 * 60
        let elapsedSeconds = now.timeIntervalSince(startDate)
        let calculatedProgress = elapsedSeconds / totalSeconds
        return min(max(calculatedProgress, 0.0), 1.0)
    }
    
    private var daysElapsed: Int {
        let components = Calendar.current.dateComponents([.day], from: startDate, to: now)
        return max(0, components.day ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Text("No Contact Journey")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.textOnPrimary)
            
            ZStack {
                Circle()
                    .stroke(Color.sageGreen.opacity(0.4), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        Color.sageGreen,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: progress)
                
                VStack(spacing: 8) {
                    Text("\(daysElapsed)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(Color.darkCharcoal)
                    
                    Text("Days since no contact")
                        .font(.headline)
                        .foregroundColor(Color.darkCharcoal.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if let goalDays = goalDays {
                        Text("Goal: \(Int(goalDays)) Days")
                            .font(.caption)
                            .padding(.top, 4)
                            .foregroundColor(Color.darkCharcoal.opacity(0.7))
                    } else {
                        Text("Goal: Unlimited")
                            .font(.caption)
                            .padding(.top, 4)
                            .foregroundColor(Color.darkCharcoal.opacity(0.7))
                    }
                }
            }
            .frame(width: 280, height: 280)
            
            HStack(spacing: 20) {
                timeComponentView(title: "Hours", value: Calendar.current.dateComponents([.hour], from: startDate, to: now).hour.map { $0 % 24 } ?? 0)
                timeComponentView(title: "Mins", value: Calendar.current.dateComponents([.minute], from: startDate, to: now).minute.map { $0 % 60 } ?? 0)
                timeComponentView(title: "Secs", value: Calendar.current.dateComponents([.second], from: startDate, to: now).second.map { $0 % 60 } ?? 0)
            }
            .padding()
            .background(Color.sageGreen.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button("Reset Tracker") {
                onReset()
            }
            .font(.headline)
            .padding()
            .background(Color.warmGray)
            .foregroundStyle(.red)
            .clipShape(Capsule())
            .padding(.top, 20)
        }
        .onReceive(timer) { _ in
            now = Date()
        }
    }
    
    private func timeComponentView(title: String, value: Int) -> some View {
        VStack {
            Text(String(format: "%02d", max(0, value)))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.darkCharcoal)
            Text(title)
                .font(.caption)
                .foregroundColor(Color.darkCharcoal.opacity(0.8))
        }
        .frame(width: 60)
    }
}
