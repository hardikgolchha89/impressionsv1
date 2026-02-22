//
//  MapWidget.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 10/02/26.
//

import SwiftUI

// MARK: - MapData Model
struct MapData: Identifiable {
    let id: String
    let placeName: String
    let address: String
    let latitude: Double?
    let longitude: Double?

    init(id: String = UUID().uuidString, placeName: String, address: String, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = id
        self.placeName = placeName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - MapWidget View
struct MapWidget: View {
    let map: MapData

    var body: some View {
        VStack(alignment: .center, spacing: Spacing.xs) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)

            Text(map.placeName)
                .font(.custom("HKGrotesk-SemiBold", size: 12))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(map.address)
                .font(.custom("HKGrotesk-Light", size: 11))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text("See places nearby →")
                .font(.custom("HKGrotesk-Light", size: 10))
                .italic()
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBlue)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        MapWidget(map: MapData(
            id: "1",
            placeName: "Kamala Mills",
            address: "Compound, Lower Parel, Mumbai"
        ))

        MapWidget(map: MapData(
            id: "2",
            placeName: "The Bombay Canteen",
            address: "Lower Parel, Mumbai"
        ))
    }
    .padding()
}
