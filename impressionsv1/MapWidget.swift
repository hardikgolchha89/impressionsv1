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
        VStack(alignment: .center, spacing: 0) {
            // Map pin icon
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            // Place name + address (combined)
            Text("\(map.placeName)\n\(map.address)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(0.8)
                .lineLimit(3)
                .padding(.bottom, 10)
            
            // Action link
            Text("See places nearby →")
                .font(.system(size: 11, weight: .medium))
                .italic()
                .foregroundColor(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(Color.appBlue)
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        MapWidget(map: MapData(
            id: "1",
            placeName: "Kamala Mills",
            address: "Compound, Lower Parel, Mumbai",
            latitude: nil,
            longitude: nil
        ))
        
        MapWidget(map: MapData(
            id: "2",
            placeName: "The Bombay Canteen",
            address: "Lower Parel, Mumbai",
            latitude: nil,
            longitude: nil
        ))
    }
    .padding()
}
