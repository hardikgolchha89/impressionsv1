//
//  PlaceSelectionView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

// MARK: - Data Model
struct Place: Identifiable {
    let id: UUID
    let name: String
    let imageURL: String
    let location: String?
    
    init(id: UUID = UUID(), name: String, imageURL: String, location: String? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.location = location
    }
}

// MARK: - View
struct PlaceSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var selectedPlace: Place? = nil
    @State private var searchText: String = ""
    
    // Sample data with SF Symbol placeholders
    private let samplePlaces: [Place] = [
        Place(name: "The Bombay Canteen", imageURL: "fork.knife"),
        Place(name: "Lake View Cafe", imageURL: "cup.and.saucer.fill"),
        Place(name: "Bastian - At the Top", imageURL: "building.2.fill"),
        Place(name: "Boneto Fine Dine", imageURL: "wineglass.fill"),
        Place(name: "Bandra Born", imageURL: "sparkles"),
        Place(name: "Nksha", imageURL: "leaf.fill"),
        Place(name: "Tanatan Shivaji Park", imageURL: "flame.fill"),
        Place(name: "Delhi Darbar", imageURL: "building.fill"),
        Place(name: "Kyani & Co.", imageURL: "cup.and.saucer"),
        Place(name: "Submit New Restaurants Here", imageURL: "plus.circle.fill")
    ]
    
    // Filtered places based on search
    private var filteredPlaces: [Place] {
        let places: [Place]
        if searchText.isEmpty {
            places = samplePlaces
        } else {
            places = samplePlaces.filter { place in
                place.name.localizedCaseInsensitiveContains(searchText)
            }
            // Always include "Submit New Restaurants" option even when searching
            let submitOption = samplePlaces.last!
            if !places.contains(where: { $0.id == submitOption.id }) {
                return places + [submitOption]
            }
        }
        return places
    }
    
    // Grid columns configuration
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 0) {
                    HStack {
                        // Back button
                        Button(action: {
                            coordinator.goBack()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.textPrimary)
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        // Title
                        Text("Where did you go?")
                            .font(AppFont.title2)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        // Balance spacing
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.xs)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textTertiary)
                            .padding(.leading, Spacing.sm)
                        
                        TextField("Search", text: $searchText)
                            .font(AppFont.body)
                            .foregroundColor(.textPrimary)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.textTertiary)
                                    .padding(.trailing, Spacing.sm)
                            }
                        }
                    }
                    .frame(height: 44)
                    .background(Color.cardBackground)
                    .cornerRadius(CornerRadius.medium)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                }
                
                // Place Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: Spacing.sm) {
                        ForEach(filteredPlaces) { place in
                            PlaceCard(
                                place: place,
                                isSelected: selectedPlace?.id == place.id
                            ) {
                                // Toggle selection
                                if selectedPlace?.id == place.id {
                                    selectedPlace = nil
                                } else {
                                    selectedPlace = place
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.xl)
                }
                
                // Continue Button (reserve space to prevent grid shift)
                VStack {
                    if let place = selectedPlace {
                        Button(action: {
                            coordinator.completePlace(place: place)
                        }) {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                        }
                        .primaryButton()
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.md)
                        .transition(.opacity)
                    } else {
                        // Invisible spacer to maintain layout
                        Color.clear
                            .frame(height: 60)
                            .padding(.bottom, Spacing.md)
                    }
                }
                .background(Color.appBackground)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Place Card Component
struct PlaceCard: View {
    let place: Place
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack(alignment: .topTrailing) {
                // Image
                Image(systemName: place.imageURL)
                    .font(.system(size: 40))
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color.cardBackground)
                    .cornerRadius(CornerRadius.large)
                
                // Selection checkmark
                if isSelected {
                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.small)
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(8)
                }
            }
            
            // Name label
            Text(place.name)
                .font(AppFont.bodySmall)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    PlaceSelectionView(coordinator: CreateImpressionCoordinator())
}
