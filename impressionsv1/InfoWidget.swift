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
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Title (if provided)
            if let title = info.title {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appDarkText)
                    .lineLimit(2)
            }
            
            // Content text
            Text(info.content)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.appDarkText)
                .lineSpacing(1.3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.appBlue)
        .cornerRadius(CornerRadius.widget)
        .frame(minHeight: 120, alignment: .top)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Spacing.md) {
        // Info 1 - With title
        InfoWidget(info: InfoData(
            id: "1",
            title: "What was the vibe?",
            content: "Kanda MH Gandhipuram Dadar 12:31 PM to 12:40 PM"
        ))
        
        // Info 2 - With title
        InfoWidget(info: InfoData(
            id: "2",
            title: "How much did you spend?",
            content: "We were 7 of us (2 adults). Price per person came around 700/-"
        ))
        
        // Info 3 - No title
        InfoWidget(info: InfoData(
            id: "3",
            content: "The place gets crowded after 8 PM. Best to arrive early or make a reservation."
        ))
        
        // Side by side example
        HStack(spacing: Spacing.md) {
            InfoWidget(info: InfoData(
                id: "4",
                title: "What was the vibe?",
                content: "Kanda MH Gandhipuram Dadar 12:31 PM to 12:40 PM"
            ))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            InfoWidget(info: InfoData(
                id: "5",
                title: "How much did you spend?",
                content: "We were 7 of us (2 adults). Price per person came around 700/-"
            ))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding()
    .background(Color(hex: "F5F5F5"))
}
