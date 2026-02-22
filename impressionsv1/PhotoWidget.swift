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
        ZStack(alignment: .bottomLeading) {
            // Photo or Placeholder — fills the grid cell
            if let imageUrl = photo.imageUrl, !imageUrl.isEmpty,
               let uiImage = UIImage(named: imageUrl) ?? UIImage(contentsOfFile: imageUrl) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                photoPlaceholder
            }

            // Caption overlay (if provided)
            if let caption = photo.caption, !caption.isEmpty {
                Text(caption)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.image, style: .continuous))
    }

    // MARK: - Placeholder View
    private var photoPlaceholder: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "photo")
                .font(.system(size: 32))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
