// HomeWorth/ColorTheme.swift
import SwiftUI

extension Color {
    // Primary brand color
    static let homeWorthYellow = Color(red: 255/255, green: 220/255, blue: 0/255)
    
    // Light gray for backgrounds
    static let homeWorthLightGray = Color(red: 245/255, green: 245/255, blue: 245/255)
    
    // Dark gray for text and secondary elements
    static let homeWorthDarkGray = Color(red: 50/255, green: 50/255, blue: 50/255)
    
    // Gradient colors
    static let homeWorthGradientStart = Color(red: 255/255, green: 235/255, blue: 100/255)
    static let homeWorthGradientEnd = Color(red: 255/255, green: 200/255, blue: 0/255)
    
    // Futuristic additions
    static let neonYellow = Color(red: 255/255, green: 255/255, blue: 0/255)
    static let deepBlack = Color(red: 10/255, green: 10/255, blue: 15/255)
    static let softWhite = Color(red: 250/255, green: 250/255, blue: 250/255)
    static let glowYellow = Color(red: 255/255, green: 220/255, blue: 0/255).opacity(0.3)
    static let cardBackground = Color(red: 20/255, green: 20/255, blue: 25/255)
    static let borderYellow = Color(red: 255/255, green: 220/255, blue: 0/255).opacity(0.6)
}

// Futuristic UI Components
struct GlowEffect: ViewModifier {
    let color: Color
    let intensity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: intensity)
            .shadow(color: color, radius: intensity * 0.5)
            .shadow(color: color, radius: intensity * 0.25)
    }
}

struct NeonBorder: ViewModifier {
    @State private var isGlowing = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.homeWorthYellow, lineWidth: isGlowing ? 2 : 1)
                    .modifier(GlowEffect(color: .homeWorthYellow, intensity: isGlowing ? 8 : 4))
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isGlowing.toggle()
                }
            }
    }
}

extension View {
    func neonGlow(color: Color = .homeWorthYellow, intensity: CGFloat = 6) -> some View {
        self.modifier(GlowEffect(color: color, intensity: intensity))
    }
    
    func neonBorder() -> some View {
        self.modifier(NeonBorder())
    }
}
