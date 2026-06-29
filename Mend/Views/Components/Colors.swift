//
//  Colors.swift
//  Mend
//
//  Created by Shehani Hansika on 07.05.26.
//
import SwiftUI

// MARK: - Dynamic Color Helper
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traits in
            return traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

extension Color {
    // MARK: - Calm & Grounding Palette (Purple & Sand)
    static let darkCharcoal = Color(red: 48/255, green: 40/255, blue: 56/255) // Deep Plum
    static let mutedForest  = Color(red: 30/255, green: 24/255, blue: 38/255) // Near Black Purple
    static let sageGreen    = Color(red: 163/255, green: 145/255, blue: 178/255) // Lavender/Mauve
    static let softSand     = Color(red: 248/255, green: 246/255, blue: 250/255) // Light Purple-tinted Off-White
    static let warmGray     = Color(red: 236/255, green: 232/255, blue: 240/255) // Pale Lilac Gray
    
    // MARK: - Brand Colors
    // A soothing sage green fits the "healing/calm" theme perfectly
    static let brandPrimary = darkCharcoal
    
    // Auto-contrasts against the background (Dark Charcoal in Light mode, Soft Sand in Dark mode)
    static let textOnPrimary = Color(
        light: darkCharcoal,
        dark: darkCharcoal
    )
    
    // Button Text Color (White/Sand for inside Sage buttons)
    static let buttonText = softSand
    
    // MARK: - App Background Gradient
    // Light Mode: Very soft, warm off-white merging into a very light warm-gray
    // Dark Mode: Muted forest tones, deep and grounded without being harshly black
    static let bgTop = Color(
        light: Color(red: 252/255, green: 252/255, blue: 250/255),
        dark: sageGreen
    )
    static let bgMiddle = Color(
        light: Color(red: 247/255, green: 248/255, blue: 245/255),
        dark: sageGreen
    )
    static let bgBottom = Color(
        light: Color(red: 230/255, green: 232/255, blue: 228/255),
        dark: sageGreen
    )
    
    static let appBackgroundGradient = LinearGradient(
        colors: [bgTop, bgMiddle, bgBottom],
        startPoint: .top,
        endPoint: .bottom
    )
}
