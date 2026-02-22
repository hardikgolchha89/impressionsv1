//
//  PairingWidget.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 08/02/26.
//

import SwiftUI

// MARK: - Data Model
struct PairingWidgetData: Identifiable {
    let id: String
    let placeName: String
    let location: String
    let imageUrl: String?
    
    init(id: String = UUID().uuidString, placeName: String, location: String, imageUrl: String? = nil) {
        self.id = id
        self.placeName = placeName
        self.location = location
        self.imageUrl = imageUrl
    }
}

// MARK: - Widget View
struct PairingWidget: View {
    let pairing: PairingWidgetData
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side - Text content (60%)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("I'd pair this up with")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text(pairing.placeName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(pairing.location)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(16)

            // Right side - Photo placeholder (40%)
            ZStack {
                Color.gray.opacity(0.3)
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(-1)   // let text side take priority
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appGreen)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.widget, style: .continuous))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Spacing.md) {
        PairingWidget(pairing: PairingWidgetData(
            id: "1",
            placeName: "Bombay Sweet Shop",
            location: "Palladium Mall",
            imageUrl: nil
        ))
        
        PairingWidget(pairing: PairingWidgetData(
            id: "2",
            placeName: "Collin's",
            location: "Malad",
            imageUrl: nil
        ))
    }
    .padding()
    .background(Color(hex: "F5F5F5"))
}
