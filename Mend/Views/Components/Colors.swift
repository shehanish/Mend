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
    // MARK: - Healing Purple Palette
    static let darkCharcoal = Color(red: 76/255, green: 43/255, blue: 111/255) // Deep violet plum
    static let mutedForest  = Color(red: 52/255, green: 31/255, blue: 78/255) // Rich eggplant
    static let sageGreen    = Color(red: 176/255, green: 146/255, blue: 214/255) // Lavender mauve
    static let softSand     = Color(red: 252/255, green: 248/255, blue: 255/255) // Soft lilac white
    static let warmGray     = Color(red: 238/255, green: 228/255, blue: 248/255) // Pale orchid gray
    
    // MARK: - Brand Colors
    // A healing purple keeps the app calm but more expressive and colorful
    static let brandPrimary = darkCharcoal
    
    // Auto-contrasts against the background while staying readable
    static let textOnPrimary = Color(
        light: mutedForest,
        dark: softSand
    )
    
    // Button Text Color (White/Sand for inside Sage buttons)
    static let buttonText = softSand
    
    // MARK: - App Background Gradient
    // Light Mode: Soft lilac sky with a warm orchid tint
    // Dark Mode: Deep plum and muted violet tones
    static let bgTop = Color(
        light: Color(red: 251/255, green: 245/255, blue: 255/255),
        dark: mutedForest
    )
    static let bgMiddle = Color(
        light: Color(red: 244/255, green: 236/255, blue: 255/255),
        dark: darkCharcoal
    )
    static let bgBottom = Color(
        light: Color(red: 233/255, green: 220/255, blue: 248/255),
        dark: sageGreen
    )
    
    static let appBackgroundGradient = LinearGradient(
        colors: [bgTop, bgMiddle, bgBottom],
        startPoint: .top,
        endPoint: .bottom
    )
}
