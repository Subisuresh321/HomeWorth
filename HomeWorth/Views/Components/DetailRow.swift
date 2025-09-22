// HomeWorth/Views/Components/DetailRow.swift
import SwiftUI

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon with consistent styling
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.deepBlack)
                .frame(width: 24, height: 24)
            
            // Label
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.deepBlack.opacity(0.8))
            
            Spacer()
            
            // Value
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.deepBlack)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
    }
}
