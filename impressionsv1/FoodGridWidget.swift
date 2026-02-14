//
//  FoodGridWidget.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 08/02/26.
//

import SwiftUI

// MARK: - Data Model
struct FoodItem: Identifiable {
    let id: String
    let name: String
    let imageName: String?
    
    init(id: String = UUID().uuidString, name: String, imageName: String? = nil) {
        self.id = id
        self.name = name
        self.imageName = imageName
    }
}

struct FoodGridData: Identifiable {
    let id: String
    let items: [FoodItem]
    
    init(id: String = UUID().uuidString, items: [FoodItem]) {
        self.id = id
        self.items = items
    }
}

// MARK: - Widget View
struct FoodGridWidget: View {
    let items: [FoodItem]
    
    var body: some View {
        // Green container
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(items) { item in
                        FoodItemView(item: item)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(Color.appGreen)
        .cornerRadius(CornerRadius.widget)
    }
}

// MARK: - Food Item View
struct FoodItemView: View {
    let item: FoodItem
    
    var body: some View {
        VStack(spacing: 6) {
            // Food icon/image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            // Food name
            Text(item.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 60)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        FoodGridWidget(items: [
            FoodItem(id: "1", name: "Plain Podi Ghee Dosa"),
            FoodItem(id: "2", name: "Scrambled Eggs"),
            FoodItem(id: "3", name: "Canteen Rasgulla"),
            FoodItem(id: "4", name: "Butter Sada Dosa"),
            FoodItem(id: "5", name: "Filter Coffee"),
            FoodItem(id: "6", name: "Masala Dosa")
        ])
        
        Spacer()
    }
    .padding()
    .background(Color(hex: "F5F5F5"))
}
