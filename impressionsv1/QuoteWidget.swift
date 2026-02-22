//
//  QuoteWidget.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 08/02/26.
//

import SwiftUI

// MARK: - Data Model
struct QuoteData: Identifiable {
    let id: String
    let prompt: String
    let answer: String
    
    init(id: String = UUID().uuidString, prompt: String, answer: String) {
        self.id = id
        self.prompt = prompt
        self.answer = answer
    }
}

// MARK: - Widget View
struct QuoteWidget: View {
    let quote: QuoteData
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Question/Prompt — thin, smaller
            Text(quote.prompt)
                .font(.custom("HKGrotesk-Light", size: 11))
                .foregroundColor(.appDarkText.opacity(0.75))
                .lineLimit(3)
                .lineSpacing(2)

            // Answer Text — bold contrast
            Text(quote.answer)
                .font(.custom("HKGrotesk-SemiBold", size: 12))
                .foregroundColor(.appDarkText)
                .lineLimit(4)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
        .background(Color.appYellow)
        .cornerRadius(CornerRadius.widget)
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: Spacing.md) {
        QuoteWidget(quote: QuoteData(
            id: "1",
            prompt: "What did you notice that most people wouldn't?",
            answer: "They were sha dishes they like. If you speak to them and not just repeating the menu listings."
        ))
        
        QuoteWidget(quote: QuoteData(
            id: "2",
            prompt: "What made you think 'okay, they actually care here'?",
            answer: "The  just repeating the menu listings."
        ))
    }
    .padding()
    .background(Color(hex: "F5F5F5"))
}
