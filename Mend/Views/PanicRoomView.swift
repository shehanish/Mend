//
//  PanicRoomView.swift
//  Mend
//

import SwiftUI

struct PanicRoomView: View {
    @State private var vm = PanicRoomViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundGradient
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Header with Affirmation and Exit Button
                        HStack(alignment: .top) {
                            Text(vm.currentQuote)
                                .font(.title3.italic())
                                .foregroundColor(.brandPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    vm.nextQuote()
                                }
                            
                            Button(action: { dismiss() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "house.fill")
                                    Text("Home")
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.sageGreen)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Breathing Section
                        VStack(spacing: 16) {
                            Text("Guided Breathing")
                                .font(.headline)
                                .foregroundColor(.brandPrimary)
                            
                            BreathingCircleView()
                            
                            // Music Button
                            Button(action: {
                                vm.toggleMusic()
                            }) {
                                HStack {
                                    Image(systemName: vm.isPlayingMusic ? "speaker.wave.3.fill" : "speaker.slash.fill")
                                    Text(vm.isPlayingMusic ? "Playing Calming Sound" : "Play Soundscape")
                                }
                                .font(.footnote.bold())
                                .foregroundColor(.brandPrimary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.5))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)
                        
                        // Grounding Exercise Card 
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Grounding Technique (5-4-3-2-1)")
                                .font(.headline)
                                .foregroundColor(.brandPrimary)
                            
                            Text("Look around your environment and find:")
                                .font(.subheadline)
                                .foregroundColor(.brandPrimary.opacity(0.8))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                GroundingRow(number: "5", text: "Things you can see", icon: "eye.fill")
                                GroundingRow(number: "4", text: "Things you can touch", icon: "hand.tap.fill")
                                GroundingRow(number: "3", text: "Things you can hear", icon: "ear.fill")
                                GroundingRow(number: "2", text: "Things you can smell", icon: "nose.fill")
                                GroundingRow(number: "1", text: "Thing you can taste", icon: "mouth.fill")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)
                        
                        // Doodle Pad
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Simple Distraction Pad")
                                    .font(.headline)
                                    .foregroundColor(.brandPrimary)
                                Spacer()
                                Button("Clear") { vm.clearDoodles() }
                                    .font(.footnote)
                                    .foregroundColor(.brandPrimary)
                            }
                            
                            Canvas { context, size in
                                for line in vm.doodleLines {
                                    var path = Path()
                                    path.addLines(line.points)
                                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                                }
                            }
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { value in
                                    let isNew = (value.translation.width + value.translation.height == 0)
                                    vm.addDoodlePoint(value.location, isNew: isNew)
                                }
                            )
                            .frame(height: 180)
                            .background(Color.white.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding()
                        .background(Color.white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)
                        
                        // Vent Text Box
                        @Bindable var bindableVM = vm
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Private Vent Space")
                                .font(.headline)
                                .foregroundColor(.brandPrimary)
                            Text("Type whatever is on your mind. This won't be saved or read by anyone.")
                                .font(.caption)
                                .foregroundColor(.brandPrimary.opacity(0.7))
                            
                            TextEditor(text: $bindableVM.ventText)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color.white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .environment(\.colorScheme, .light)
                                .scrollContentBackground(.hidden)
                        }
                        .padding()
                        .background(Color.white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)

                        // Quick Help Contacts
                        VStack(spacing: 12) {
                            Text("Quick Help")
                                .font(.headline)
                                .foregroundColor(.brandPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ResourceButton(
                                title: "Call Emergency",
                                icon: "phone.fill",
                                subLabel: "911",
                                color: .red) {
                                vm.callEmergency("911")
                            }
                            
                            ResourceButton(
                                title: "Crisis Text Line",
                                icon: "message.fill",
                                subLabel: "Text HOME to 741741",
                                color: .blue) {
                                vm.textEmergency("741741")
                            }
                            
                            ResourceButton(
                                title: "Suicide & Crisis Lifeline",
                                icon: "phone.fill",
                                subLabel: "Call or text 988",
                                color: .brandPrimary) {
                                vm.callEmergency("988")
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    PanicRoomView()
}
