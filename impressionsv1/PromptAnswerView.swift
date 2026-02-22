//
//  PromptAnswerView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: - View
struct PromptAnswerView: View {
    let prompt: Prompt
    let answeredCount: Int
    let existingAnswer: String?
    let existingAttachments: [MediaAttachment]
    let onAnswerSaved: (String, [MediaAttachment]) -> Void
    /// When provided, used instead of dismiss() for back/discard. Also skips dismiss() after submit.
    var onBack: (() -> Void)? = nil

    @State private var answerText: String = ""
    @State private var attachments: [MediaAttachment] = []
    @State private var showDiscardAlert: Bool = false
    @State private var showMediaPicker: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var showSizeAlert: Bool = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @FocusState private var isTextEditorFocused: Bool
    @Environment(\.dismiss) private var dismiss

    private var scheme: CategoryScheme { prompt.category.scheme }

    private var canSubmit: Bool {
        let hasText = answerText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
        let allUnderLimit = attachments.allSatisfy { !$0.isOverSizeLimit }
        return hasText && allUnderLimit
    }

    var body: some View {
        ZStack {
            Color(hex: "131313").ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack {
                    Button(action: { handleBackButton() }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "232323"))
                                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                                .frame(width: 36, height: 36)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    Spacer()
                    Text("\(answeredCount) answered")
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.4))
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // MARK: Prompt card
                        PromptDisplayCard(prompt: prompt)
                            .padding(.horizontal, 20)

                        // MARK: Answer text editor
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(hex: "1C1C1C"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                                )

                            TextEditor(text: $answerText)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .textInputAutocapitalization(.sentences)
                                .keyboardType(.default)
                                .focused($isTextEditorFocused)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 150)
                                .padding(16)

                            if answerText.isEmpty {
                                Text("Write your answer\u{2026}")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white.opacity(0.25))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 24)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(.horizontal, 20)

                        // MARK: Attachments grid
                        if !attachments.isEmpty {
                            attachmentsSection
                                .padding(.horizontal, 20)
                        }

                        // MARK: Add media bar
                        mediaBar
                            .padding(.horizontal, 20)

                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 4)
                }

                // MARK: Submit button
                VStack(spacing: 0) {
                    Button(action: { handleSubmit() }) {
                        Text("Save Answer")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(canSubmit ? .black : Color.white.opacity(0.3))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(canSubmit ? Color.white : Color(hex: "242424"))
                                    GrainTextureView(opacity: 0.04)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(
                                            canSubmit ? Color.clear : Color.white.opacity(0.08),
                                            lineWidth: 1
                                        )
                                }
                            )
                    }
                    .disabled(!canSubmit)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 32)
                .padding(.top, 8)
                .background(Color(hex: "131313"))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            answerText = existingAnswer ?? ""
            attachments = existingAttachments
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextEditorFocused = true
            }
        }
        .alert("Discard answer?", isPresented: $showDiscardAlert) {
            Button("Discard", role: .destructive) {
                if let onBack = onBack { onBack() } else { dismiss() }
            }
            Button("Keep Writing", role: .cancel) { }
        }
        .alert("File too large", isPresented: $showSizeAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Each attachment must be under 2 MB.")
        }
        .onChange(of: selectedPhotoItems) { _, newItems in
            Task { await loadSelectedPhotos(newItems) }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.audio, .mpeg4Audio, .mp3, .wav],
            allowsMultipleSelection: false
        ) { result in
            handleAudioImport(result)
        }
    }

    // MARK: - Media Bar

    private var mediaBar: some View {
        HStack(spacing: 12) {
            Text("Attach")
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.35))

            // Photo picker
            PhotosPicker(
                selection: $selectedPhotoItems,
                maxSelectionCount: 3 - attachments.filter({ $0.type == .image }).count,
                matching: .images
            ) {
                mediaButton(icon: "photo", label: "Photo")
            }

            // Video picker
            PhotosPicker(
                selection: $selectedPhotoItems,
                maxSelectionCount: 1,
                matching: .videos
            ) {
                mediaButton(icon: "video", label: "Video")
            }

            // Audio file picker
            Button(action: { showFilePicker = true }) {
                mediaButton(icon: "mic", label: "Audio")
            }

            Spacer()
        }
    }

    private func mediaButton(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(label)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(Color.white.opacity(0.5))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(hex: "1C1C1C"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    // MARK: - Attachments Section

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Attachments")
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.35))

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                ForEach(attachments) { attachment in
                    AttachmentThumbnail(attachment: attachment) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            attachments.removeAll { $0.id == attachment.id }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Media Loading

    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            // Determine if it's a video or image
            if item.supportedContentTypes.contains(.movie) || item.supportedContentTypes.contains(.video) {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let attachment = MediaAttachment(type: .video, data: data, fileName: "video.mp4")
                    if attachment.isOverSizeLimit {
                        await MainActor.run { showSizeAlert = true }
                    } else {
                        await MainActor.run {
                            withAnimation { attachments.append(attachment) }
                        }
                    }
                }
            } else {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let attachment = MediaAttachment(type: .image, data: data, fileName: "photo.jpg")
                    if attachment.isOverSizeLimit {
                        await MainActor.run { showSizeAlert = true }
                    } else {
                        await MainActor.run {
                            withAnimation { attachments.append(attachment) }
                        }
                    }
                }
            }
        }
        // Reset selection so user can pick again
        await MainActor.run { selectedPhotoItems = [] }
    }

    private func handleAudioImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            if let data = try? Data(contentsOf: url) {
                let fileName = url.lastPathComponent
                let attachment = MediaAttachment(type: .audio, data: data, fileName: fileName)
                if attachment.isOverSizeLimit {
                    showSizeAlert = true
                } else {
                    withAnimation { attachments.append(attachment) }
                }
            }
        case .failure(let error):
            print("Audio import failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func handleBackButton() {
        let trimmed = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty && attachments.isEmpty {
            if let onBack = onBack { onBack() } else { dismiss() }
        } else {
            showDiscardAlert = true
        }
    }

    private func handleSubmit() {
        let trimmed = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count >= 10 {
            onAnswerSaved(trimmed, attachments)
            if onBack == nil { dismiss() }
        }
    }
}

// MARK: - Attachment Thumbnail

struct AttachmentThumbnail: View {
    let attachment: MediaAttachment
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(hex: "1C1C1C"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            attachment.isOverSizeLimit
                                ? Color.red.opacity(0.6)
                                : Color.white.opacity(0.08),
                            lineWidth: 1
                        )
                )
                .aspectRatio(1, contentMode: .fit)
                .overlay(thumbnailContent)

            // Remove button
            Button(action: onRemove) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "333333"))
                        .frame(width: 22, height: 22)
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .offset(x: 4, y: -4)
        }
    }

    @ViewBuilder
    private var thumbnailContent: some View {
        switch attachment.type {
        case .image:
            if let uiImage = UIImage(data: attachment.data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        case .video:
            VStack(spacing: 6) {
                Image(systemName: "video.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.5))
                Text(attachment.formattedSize)
                    .font(.system(size: 10))
                    .foregroundColor(attachment.isOverSizeLimit ? .red : Color.white.opacity(0.35))
            }
        case .audio:
            VStack(spacing: 6) {
                Image(systemName: "waveform")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.5))
                Text(attachment.fileName)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.35))
                    .lineLimit(1)
                Text(attachment.formattedSize)
                    .font(.system(size: 10))
                    .foregroundColor(attachment.isOverSizeLimit ? .red : Color.white.opacity(0.35))
            }
            .padding(.horizontal, 6)
        }
    }
}

// MARK: - Prompt Display Card — matches PromptSelectionView box-over-box style
struct PromptDisplayCard: View {
    let prompt: Prompt

    private var scheme: CategoryScheme { prompt.category.scheme }
    private let frameWidth: CGFloat = 8

    var body: some View {
        ZStack {
            // Outer pastel box
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(scheme.outerBg)
                .shadow(color: scheme.shadow, radius: 14, x: 0, y: 8)

            // Inner vivid box
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(scheme.innerBg)
                .overlay(
                    GrainTextureView(opacity: 0.10)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.30), Color.white.opacity(0.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .padding(frameWidth)

            // Question text — white
            Text(prompt.question)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(frameWidth + 14)
        }
    }
}

#Preview {
    PromptAnswerView(
        prompt: Prompt(
            question: "What did you notice that most people wouldn't?",
            category: .craftDetails
        ),
        answeredCount: 2,
        existingAnswer: nil as String?,
        existingAttachments: [],
        onAnswerSaved: { _, _ in }
    )
}
