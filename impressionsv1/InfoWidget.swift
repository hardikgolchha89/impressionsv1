//
//  InfoWidget.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 08/02/26.
//

import SwiftUI

// MARK: - Data Model
struct InfoData: Identifiable {
    let id: String
    let title: String?
    let content: String
    let icon: String?

    init(id: String = UUID().uuidString, title: String? = nil, content: String, icon: String? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.icon = icon
    }
}

// MARK: - Widget View
struct InfoWidget: View {
    let info: InfoData

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Title — thin label
            if let title = info.title {
                Text(title)
                    .font(.custom("HKGrotesk-Light", size: 11))
                    .foregroundColor(.appDarkText.opacity(0.75))
                    .lineLimit(2)
            }

            // Content — semibold contrast
            Text(info.content)
                .font(.custom("HKGrotesk-SemiBold", size: 12))
                .foregroundColor(.appDarkText)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
        .background(Color.appBlue)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.widget, style: .continuous))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Spacing.md) {
        InfoWidget(info: InfoData(
            id: "1",
            title: "What was the vibe?",
            content: "Kanda MH Gandhipuram Dadar 12:31 PM to 12:40 PM"
        ))

        InfoWidget(info: InfoData(
            id: "2",
            title: "How much did you spend?",
            content: "We were 7 of us (2 adults). Price per person came around 700/-"
        ))

        HStack(spacing: Spacing.md) {
            InfoWidget(info: InfoData(
                id: "4",
                title: "What was the vibe?",
                content: "Casual & fun"
            ))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            InfoWidget(info: InfoData(
                id: "5",
                title: "When did you go?",
                content: "Dinner"
            ))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding()
    .background(Color(hex: "F5F5F5"))
}
