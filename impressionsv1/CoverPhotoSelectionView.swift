//
//  CoverPhotoSelectionView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI
import PhotosUI

// MARK: - View
struct CoverPhotoSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var uploadedPhotos: [UIImage]
    @State private var selectedPhotoIndex: Int? = 0
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showPhotoPicker = false
    
    init(coordinator: CreateImpressionCoordinator) {
        self.coordinator = coordinator
        _uploadedPhotos = State(initialValue: coordinator.data.photos)
    }
    
    // Computed property for selected photo
    var selectedPhoto: UIImage? {
        guard let index = selectedPhotoIndex,
              uploadedPhotos.indices.contains(index) else {
            return nil
        }
        return uploadedPhotos[index]
    }
    
    var canContinue: Bool {
        selectedPhotoIndex != nil
    }
    
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
                    Text("Choose a cover photo")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Balance spacing
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
                
                // Large Preview Area - Centered vertically
                Spacer()
                
                if let selectedPhoto = selectedPhoto {
                    // Show selected photo
                    Image(uiImage: selectedPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.large)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(
                            color: AppShadow.cardMedium.color,
                            radius: AppShadow.cardMedium.radius,
                            x: AppShadow.cardMedium.x,
                            y: AppShadow.cardMedium.y
                        )
                        .padding(.horizontal, Spacing.md)
                } else {
                    // Empty state
                    RoundedRectangle(cornerRadius: CornerRadius.large)
                        .fill(Color.cardBackground)
                        .frame(height: 300)
                        .overlay(
                            VStack(spacing: Spacing.sm) {
                                Image(systemName: "camera")
                                    .font(.system(size: 40))
                                    .foregroundColor(.textTertiary)
                                
                                Text("No photo selected")
                                    .font(AppFont.body)
                                    .foregroundColor(.textTertiary)
                            }
                        )
                        .padding(.horizontal, Spacing.md)
                }
                
                Spacer()
                
                // Thumbnail Strip
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.xs) {
                            // Photo thumbnails
                            ForEach(Array(uploadedPhotos.enumerated()), id: \.offset) { index, photo in
                                ThumbnailItem(
                                    photo: photo,
                                    isSelected: selectedPhotoIndex == index
                                ) {
                                    selectedPhotoIndex = index
                                }
                                .id(index)
                            }
                            
                            // Add Photo Button
                            AddPhotoButton {
                                showPhotoPicker = true
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                    .frame(height: 80)
                    .onChange(of: selectedPhotoIndex) { newIndex in
                        if let newIndex = newIndex {
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                }
                .padding(.bottom, Spacing.md)
                
                // Continue Button
                VStack {
                    Button(action: {
                        if let photo = selectedPhoto {
                            coordinator.completeCoverPhoto(photo: photo)
                        }
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryButton()
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.md)
                    .disabled(!canContinue)
                    .opacity(canContinue ? 1.0 : 0.5)
                }
                .background(Color.appBackground)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Auto-select first photo if available
            if uploadedPhotos.isEmpty {
                selectedPhotoIndex = nil
            } else if selectedPhotoIndex == nil || selectedPhotoIndex! >= uploadedPhotos.count {
                selectedPhotoIndex = 0
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedItem) { newItem in
            Task {
                if let newItem = newItem {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        // Resize image to max 1024x1024
                        let resizedImage = resizeImage(image, maxDimension: 1024)
                        uploadedPhotos.append(resizedImage)
                        // Auto-select newly added photo
                        selectedPhotoIndex = uploadedPhotos.count - 1
                    }
                    selectedItem = nil
                }
            }
        }
    }
    
    // MARK: - Helper Methods
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

// MARK: - Thumbnail Item Component
struct ThumbnailItem: View {
    let photo: UIImage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Thumbnail image
            Image(uiImage: photo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .stroke(
                            isSelected ? Color.white : Color.appBorder,
                            lineWidth: isSelected ? 3 : 1
                        )
                )
            
            // Selection checkmark badge
            if isSelected {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(4)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Add Photo Button Component
struct AddPhotoButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.cardBackground)
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .strokeBorder(
                            Color.textTertiary,
                            style: StrokeStyle(lineWidth: 2, dash: [5, 5])
                        )
                )
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 32))
                        .foregroundColor(.textTertiary)
                )
        }
    }
}

#Preview {
    // Create a sample image for preview
    let sampleImage = UIImage(systemName: "photo") ?? {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.gray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }()
    
    let coordinator = CreateImpressionCoordinator()
    coordinator.data.photos = [sampleImage]
    return CoverPhotoSelectionView(coordinator: coordinator)
}
