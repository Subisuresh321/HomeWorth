// HomeWorth/FontTheme.swift
import SwiftUI

struct FontTheme {
    static let heading = Font.system(size: 28, weight: .bold)
    static let body = Font.system(size: 16, weight: .regular)
    
    // Futuristic font additions
    static let heroTitle = Font.system(size: 32, weight: .black, design: .rounded)
    static let subTitle = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let caption = Font.system(size: 14, weight: .medium, design: .monospaced)
    static let neonText = Font.system(size: 20, weight: .bold, design: .rounded)
    static let techLabel = Font.system(size: 12, weight: .medium, design: .monospaced)
}

// Futuristic Text Styles
struct NeonTextStyle: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.deepBlack)
            .fontWeight(.bold)
            .shadow(color: .homeWorthYellow.opacity(0.8), radius: isAnimating ? 8 : 4)
            .shadow(color: .homeWorthYellow.opacity(0.4), radius: isAnimating ? 16 : 8)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating.toggle()
                }
            }
    }
}

extension Text {
    func neonStyle() -> some View {
        self.modifier(NeonTextStyle())
    }
}
