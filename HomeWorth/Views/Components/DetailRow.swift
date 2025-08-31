//
//  DetailRow.swift
//  HomeWorth
//
//  Created by Subi Suresh on 27/08/2025.
//


// HomeWorth/Views/Components/DetailRow.swift
import SwiftUI

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}