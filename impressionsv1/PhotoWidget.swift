//
//  PhotoWidget.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 08/02/26.
//

import SwiftUI

// MARK: - Data Model
struct PhotoData: Identifiable {
    let id: String
    let imageUrl: String?
    let caption: String?
    
    init(id: String = UUID().uuidString, imageUrl: String? = nil, caption: String? = nil) {
        self.id = id
        self.imageUrl = imageUrl
        self.caption = caption
    }
}

// MARK: - Widget View
struct PhotoWidget: View {
    let photo: PhotoData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Photo or Placeholder
            if let imageUrl = photo.imageUrl, !imageUrl.isEmpty,
               let uiImage = UIImage(contentsOfFile: imageUrl) {
                // Load image from file path
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.image))
            } else {
                // Placeholder (shown if no image or file doesn't exist)
                photoPlaceholder
            }

            // Caption (if provided)
            if let caption = photo.caption {
                Text(caption)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.appDarkText)
                    .lineLimit(2)
            }
        }
    }

    // MARK: - Placeholder View
    private var photoPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadius.image)
                .fill(Color.gray.opacity(0.3))

            Image(systemName: "photo")
                .font(.system(size: 32))
                .foregroundColor(.gray)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Spacing.lg) {
        // Photo 1 - No caption
        PhotoWidget(photo: PhotoData(
            id: "1",
            imageUrl: nil,
            caption: nil
        ))
        
        // Photo 2 - With caption
        PhotoWidget(photo: PhotoData(
            id: "2",
            imageUrl: nil,
            caption: "The presentation was beautiful"
        ))
        
        // Side by side example
        HStack(spacing: Spacing.md) {
            PhotoWidget(photo: PhotoData(
                id: "3",
                imageUrl: nil,
                caption: nil
            ))
            .frame(maxWidth: .infinity)
            
            PhotoWidget(photo: PhotoData(
                id: "4",
                imageUrl: nil,
                caption: "Amazing plating"
            ))
            .frame(maxWidth: .infinity)
        }
    }
    .padding()
    .background(Color(hex: "F5F5F5"))
}
