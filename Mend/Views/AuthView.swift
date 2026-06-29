import SwiftUI

struct AuthView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName") var userName = ""
    @Environment(\.dismiss) var dismiss

    @State private var name = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundGradient
                    .ignoresSafeArea(.all, edges: .all)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {

                        // Icon / Illustration placeholder
                        Image(systemName: "heart.text.square.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(Color.brandPrimary)
                            .padding(.top, 40)

                        Text("Welcome to Mend")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textOnPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text("A safe space to track your healing, process your emotions, and regain your peace.")
                            .font(.body)
                            .foregroundStyle(Color.textOnPrimary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("What should we call you?")
                                .font(.headline)
                                .foregroundStyle(Color.brandPrimary)
                                .padding(.horizontal, 4)

                            TextField("Enter your name", text: $name)
                                .textInputAutocapitalization(.words)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(Color.darkCharcoal)
                        }
                        .environment(\.colorScheme, .light)
                        .padding(.horizontal, 30)

                        Button(action: {
                            // Save name
                            userName = name.trimmingCharacters(in: .whitespaces).isEmpty ? "Friend" : name.trimmingCharacters(in: .whitespaces)
                            
                            // Mark onboarding/login as complete
                            isLoggedIn = true
                            dismiss()
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.brandPrimary.opacity(0.5) : Color.brandPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(Color.brandPrimary)
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
