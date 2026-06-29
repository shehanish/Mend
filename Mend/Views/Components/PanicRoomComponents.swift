//
//  PanicRoomComponents.swift
//  Mend
//

import SwiftUI

struct BreathingCircleView: View {
    @State private var isBreathing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.sageGreen.opacity(0.2))
                .frame(width: isBreathing ? 240 : 120, height: isBreathing ? 240 : 120)
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: isBreathing)
            
            Circle()
                .fill(Color.sageGreen.opacity(0.4))
                .frame(width: isBreathing ? 180 : 90, height: isBreathing ? 180 : 90)
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: isBreathing)
            
            Circle()
                .fill(Color.sageGreen)
                .frame(width: 80, height: 80)
            
            Text(isBreathing ? "Exhale" : "Inhale")
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: isBreathing)
        }
        .frame(height: 250)
        .onAppear {
            isBreathing.toggle()
        }
    }
}

struct GroundingRow: View {
    let number: String
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.sageGreen)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.brandPrimary)
            
            Spacer()
            
            Image(systemName: icon)
                .foregroundColor(.sageGreen.opacity(0.8))
        }
    }
}

struct ResourceButton: View {
    let title: String
    let icon: String
    let subLabel: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.textOnPrimary)
                    Text(subLabel)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(color.opacity(0.5))
            }
            .padding()
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct DoodleLine {
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}
