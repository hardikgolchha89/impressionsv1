//
//  OrderListWidget.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 08/02/26.
//

import SwiftUI

// MARK: - Data Model
struct OrderItem: Identifiable {
    let id: String
    let name: String
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
}

struct OrderListData: Identifiable {
    let id: String
    let title: String
    let leftColumnItems: [OrderItem]
    let rightColumnItems: [OrderItem]
    
    init(id: String = UUID().uuidString, title: String, leftColumnItems: [OrderItem], rightColumnItems: [OrderItem] = []) {
        self.id = id
        self.title = title
        self.leftColumnItems = leftColumnItems
        self.rightColumnItems = rightColumnItems
    }
}

// MARK: - Widget View
struct OrderListWidget: View {
    let title: String
    let leftColumnItems: [OrderItem]
    let rightColumnItems: [OrderItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, Spacing.lg)
            
            // Two Column Layout
            HStack(alignment: .top, spacing: Spacing.xl) {
                // Left Column
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ForEach(leftColumnItems) { item in
                        Text(item.name)
                            .font(.system(size: 15, weight: .regular))
                            .italic()
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Right Column
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ForEach(rightColumnItems) { item in
                        Text(item.name)
                            .font(.system(size: 15, weight: .regular))
                            .italic()
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .background(Color.appGreen)
        .cornerRadius(CornerRadius.widget)
    }
}

// MARK: - Preview
#Preview {
    OrderListWidget(
        title: "What did you order for the table?",
        leftColumnItems: [
            OrderItem(id: "1", name: "Scramble Egg Quesadillas"),
            OrderItem(id: "2", name: "Akuri"),
            OrderItem(id: "3", name: "Strawberry and White Chocolate waffle"),
            OrderItem(id: "4", name: "spinach & ricotta Ravioli"),
            OrderItem(id: "5", name: "smoky paprika penne")
        ],
        rightColumnItems: [
            OrderItem(id: "6", name: "Akuri"),
            OrderItem(id: "7", name: "Strawberry Smoothie")
        ]
    )
    .padding()
    .background(Color(hex: "F5F5F5"))
}
