//
//  PhotoUploadView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI
import PhotosUI

// MARK: - View
struct PhotoUploadView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var selectedPhotos: [Int: UIImage] = [:] // Key = slot index (0-5)
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedSlot: Int? = nil
    @State private var showActionSheet = false
    @State private var actionSheetSlot: Int? = nil
    
    // Grid columns configuration (3 columns)
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]
    
    // 6 photo slots (3x2 grid)
    private let photoSlots = 0..<6
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
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
                    Text("Share some photos?")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Balance spacing
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
                
                // Photo Grid - Centered vertically
                Spacer()
                
                LazyVGrid(columns: columns, spacing: Spacing.sm) {
                    ForEach(photoSlots, id: \.self) { slotIndex in
                        PhotoSlot(
                            slotIndex: slotIndex,
                            image: selectedPhotos[slotIndex],
                            onTap: {
                                handleSlotTap(slotIndex)
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
                
                Spacer()
                
                // Bottom Buttons
                VStack(spacing: Spacing.sm) {
                    // Continue Button
                    Button(action: {
                        let photos = selectedPhotos.values.map { $0 }
                        coordinator.completePhotoUpload(photos: photos)
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryButton()
                    .padding(.horizontal, Spacing.md)
                    
                    // Skip Button
                    Button(action: {
                        coordinator.completePhotoUpload(photos: [])
                    }) {
                        Text("Skip for now")
                            .frame(maxWidth: .infinity)
                    }
                    .secondaryButton()
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.md)
                }
                .background(Color.appBackground)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .photosPicker(
            isPresented: Binding(
                get: { selectedSlot != nil },
                set: { if !$0 { selectedSlot = nil } }
            ),
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let newItem = newValue, let slotIndex = selectedSlot {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        // Resize image to max 1024x1024
                        let resizedImage = resizeImage(image, maxDimension: 1024)
                        selectedPhotos[slotIndex] = resizedImage
                    }
                    selectedItem = nil
                    selectedSlot = nil
                }
            }
        }
        .confirmationDialog("Photo Options", isPresented: $showActionSheet, presenting: actionSheetSlot) { slotIndex in
            Button("Change Photo") {
                selectedSlot = slotIndex
            }
            Button("Remove Photo", role: .destructive) {
                selectedPhotos.removeValue(forKey: slotIndex)
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Helper Methods
    private func handleSlotTap(_ slotIndex: Int) {
        if selectedPhotos[slotIndex] != nil {
            // Filled slot - show action sheet
            actionSheetSlot = slotIndex
            showActionSheet = true
        } else {
            // Empty slot - open photo picker
            selectedSlot = slotIndex
        }
    }
    
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSize = max(size.width, size.height)
        
        if maxSize <= maxDimension {
            return image
        }
        
        let ratio = maxDimension / maxSize
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
}

// MARK: - Photo Slot Component
struct PhotoSlot: View {
    let slotIndex: Int
    let image: UIImage?
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = image {
                // Filled state - show image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.large)
                            .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
                    )
                
                // Checkmark badge
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(8)
            } else {
                // Empty state - show placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.large)
                        .fill(Color.cardBackground)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                    
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    PhotoUploadView(coordinator: CreateImpressionCoordinator())
}
