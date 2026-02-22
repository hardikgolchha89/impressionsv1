//
//  WidgetBuilderView.swift
//  impressionsv1
//
//  "Build your impression" — tab-filtered prompt list, bottom sheet answer entry.
//  Requires at least 3 widget answers before Preview is unlocked.
//  Each prompt can be answered with text + optional photo/audio/video attachments.
//

import SwiftUI
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: - Prompt data

private struct PromptItem: Identifiable {
    let id = UUID()
    let category: WidgetCategory
    let question: String
}

private let allPrompts: [PromptItem] = [
    // Craft & Details
    PromptItem(category: .craftAndDetails, question: "What did you notice that most people wouldn't?"),
    PromptItem(category: .craftAndDetails, question: "Did they do anything technical really well or really poorly?"),
    PromptItem(category: .craftAndDetails, question: "Was there anything about the quality of basics that stood out?"),
    PromptItem(category: .craftAndDetails, question: "What small detail made you think 'okay, they actually care here'?"),
    PromptItem(category: .craftAndDetails, question: "What would a regular at this place know to ask for or avoid?"),
    // Service
    PromptItem(category: .service, question: "How was the service — warm, efficient, forgettable?"),
    PromptItem(category: .service, question: "Did the staff make the meal better or worse?"),
    PromptItem(category: .service, question: "Was there a moment where service surprised you?"),
    // Expectations
    PromptItem(category: .expectations, question: "Did it live up to the hype?"),
    PromptItem(category: .expectations, question: "What surprised you in a good way?"),
    PromptItem(category: .expectations, question: "What surprised you in a bad way?"),
    PromptItem(category: .expectations, question: "Would you go back, and for what specifically?"),
    PromptItem(category: .expectations, question: "What kind of person would love this place?"),
    // Social
    PromptItem(category: .social, question: "What's the vibe like? Does it match the occasion?"),
    PromptItem(category: .social, question: "Is this a first-date spot, or a settle-in-with-friends spot?"),
    PromptItem(category: .social, question: "How loud was it — could you hold a conversation?"),
    PromptItem(category: .social, question: "What were the other tables like?"),
    PromptItem(category: .social, question: "Would you bring your parents here?"),
]

private let minWidgets = 3

// MARK: - View

struct WidgetBuilderView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var activeTab: WidgetCategory = .craftAndDetails
    @State private var answers: [UUID: WidgetAnswer] = [:]
    @State private var activePrompt: PromptItem? = nil
    @State private var draftText: String = ""
    @State private var draftAttachments: [MediaAttachment] = []

    private var filteredPrompts: [PromptItem] {
        allPrompts.filter { $0.category == activeTab }
    }

    private var answeredList: [WidgetAnswer] {
        Array(answers.values).sorted { $0.question < $1.question }
    }

    private var canPreview: Bool { answers.count >= minWidgets }
    private var moreNeeded: Int { max(0, minWidgets - answers.count) }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appCream.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Top bar ────────────────────────────────────────────
                HStack {
                    Button { coordinator.goBack() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appBrown)
                            .frame(width: 44, height: 44)
                    }

                    Text("NEW IMPRESSION")
                        .font(.custom("HKGrotesk-SemiBold", size: 11))
                        .foregroundColor(.appBrown.opacity(0.5))
                        .kerning(0.8)

                    Spacer()

                    Text("4/4")
                        .font(.custom("HKGrotesk-Regular", size: 13))
                        .foregroundColor(.appBrown.opacity(0.45))
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Heading ────────────────────────────────────
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text("Build your impression")
                                    .font(.custom("HKGrotesk-Bold", size: 24))
                                    .foregroundColor(.appBrown)
                                Text("🌟")
                                    .font(.system(size: 20))
                            }
                            Text("Add at least \(minWidgets) widgets — pick from any category.")
                                .font(.custom("HKGrotesk-Regular", size: 13))
                                .foregroundColor(.appBrown.opacity(0.55))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 16)

                        // ── Category tabs ──────────────────────────────
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(WidgetCategory.allCases, id: \.self) { cat in
                                    let answeredInCat = answers.values.filter { $0.category == cat }.count
                                    CategoryTab(
                                        label: cat.rawValue,
                                        badge: answeredInCat,
                                        isActive: activeTab == cat
                                    ) {
                                        withAnimation(.spring(duration: 0.2)) { activeTab = cat }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 16)

                        // ── Answered widgets mini-cards ────────────────
                        if !answeredList.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("YOUR WIDGETS (\(answers.count) min)")
                                    .font(.custom("HKGrotesk-SemiBold", size: 10))
                                    .foregroundColor(.appBrown.opacity(0.4))
                                    .kerning(0.8)
                                    .padding(.horizontal, 20)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(answeredList) { wa in
                                            AnsweredWidgetCard(widget: wa) {
                                                answers.removeValue(forKey: wa.id)
                                            }
                                        }

                                        // "Add widget" placeholder
                                        VStack {
                                            Image(systemName: "plus")
                                                .font(.system(size: 18))
                                                .foregroundColor(.appBrown.opacity(0.3))
                                        }
                                        .frame(width: 140, height: 90)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                                                .foregroundColor(Color.appBrown.opacity(0.2))
                                        )
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.bottom, 16)
                        }

                        // ── Prompt section label ───────────────────────
                        Text("\(activeTab.rawValue.uppercased()) PROMPTS")
                            .font(.custom("HKGrotesk-SemiBold", size: 10))
                            .foregroundColor(.appBrown.opacity(0.4))
                            .kerning(0.8)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        // ── Prompt rows ────────────────────────────────
                        VStack(spacing: 6) {
                            ForEach(filteredPrompts) { prompt in
                                let isAnswered = answers[prompt.id] != nil
                                PromptRow(
                                    prompt: prompt,
                                    isAnswered: isAnswered
                                ) {
                                    draftText = answers[prompt.id]?.answer ?? ""
                                    draftAttachments = answers[prompt.id]?.attachments ?? []
                                    activePrompt = prompt
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                        // ── Counter ────────────────────────────────────
                        Text(canPreview
                             ? "✓ Ready to preview"
                             : "Add \(moreNeeded) more answered widget\(moreNeeded == 1 ? "" : "s") to continue")
                            .font(.custom("HKGrotesk-Regular", size: 13))
                            .foregroundColor(canPreview ? .appOlive : .appBrown.opacity(0.45))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 16)

                        // Spacer for bottom button
                        Color.clear.frame(height: 80)
                    }
                }
            }

            // ── Bottom CTA ─────────────────────────────────────────────
            Button {
                guard canPreview else { return }
                coordinator.completeWidgetBuilder(answers: answeredList)
            } label: {
                Text("Preview impression →")
            }
            .if(canPreview)  { $0.primaryButton() }
            .if(!canPreview) { $0.inactiveButton() }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .animation(.easeInOut(duration: 0.2), value: canPreview)
        }
        // ── Answer bottom sheet ────────────────────────────────────────
        .sheet(item: $activePrompt) { prompt in
            AnswerSheet(
                prompt: prompt,
                draft: $draftText,
                draftAttachments: $draftAttachments
            ) { finalText, finalAttachments in
                if !finalText.trimmingCharacters(in: .whitespaces).isEmpty || !finalAttachments.isEmpty {
                    let wa = WidgetAnswer(
                        id: prompt.id,
                        category: prompt.category,
                        question: prompt.question,
                        answer: finalText.trimmingCharacters(in: .whitespaces),
                        attachments: finalAttachments
                    )
                    withAnimation(.spring(duration: 0.25)) {
                        answers[prompt.id] = wa
                    }
                }
                activePrompt = nil
                draftText = ""
                draftAttachments = []
            } onCancel: {
                activePrompt = nil
                draftText = ""
                draftAttachments = []
            }
        }
    }
}

// MARK: - Category tab chip

private struct CategoryTab: View {
    let label: String
    let badge: Int
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.custom(isActive ? "HKGrotesk-SemiBold" : "HKGrotesk-Regular", size: 13))
                    .foregroundColor(isActive ? .white : .appBrown.opacity(0.65))
                if badge > 0 {
                    Text("\(badge)")
                        .font(.custom("HKGrotesk-SemiBold", size: 11))
                        .foregroundColor(isActive ? .white.opacity(0.8) : .appBrown.opacity(0.5))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(isActive ? Color.white.opacity(0.25) : Color.appBrown.opacity(0.1)))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isActive ? Color.appBrown : Color.appOffWhite)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Prompt row

private struct PromptRow: View {
    let prompt: PromptItem
    let isAnswered: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Colour dot
                Circle()
                    .fill(isAnswered ? prompt.category.color : Color.appGreige)
                    .frame(width: 10, height: 10)

                Text(prompt.question)
                    .font(.custom("HKGrotesk-Regular", size: 14))
                    .foregroundColor(isAnswered ? .appBrown : .appBrown.opacity(0.75))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isAnswered ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 16))
                    .foregroundColor(isAnswered ? prompt.category.color : .appGreige)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isAnswered ? prompt.category.color.opacity(0.08) : Color.appOffWhite)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Answered widget mini-card

private struct AnsweredWidgetCard: View {
    let widget: WidgetAnswer
    let onRemove: () -> Void

    private var mediaIcons: [String] {
        var icons: [String] = []
        let types = Set(widget.attachments.map(\.type))
        if types.contains(.image) { icons.append("photo") }
        if types.contains(.video) { icons.append("video") }
        if types.contains(.audio) { icons.append("waveform") }
        return icons
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(widget.category.rawValue.uppercased())
                    .font(.custom("HKGrotesk-SemiBold", size: 9))
                    .foregroundColor(widget.category.color)
                    .kerning(0.5)
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.appBrown.opacity(0.4))
                }
            }

            if widget.answer.isEmpty && !widget.attachments.isEmpty {
                // Media-only answer
                HStack(spacing: 4) {
                    ForEach(mediaIcons, id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.system(size: 12))
                            .foregroundColor(widget.category.color.opacity(0.7))
                    }
                    Text("\(widget.attachments.count) attachment\(widget.attachments.count == 1 ? "" : "s")")
                        .font(.custom("HKGrotesk-Light", size: 11))
                        .foregroundColor(.appBrown.opacity(0.6))
                }
            } else {
                Text(widget.answer)
                    .font(.custom("HKGrotesk-Light", size: 11))
                    .foregroundColor(.appBrown.opacity(0.75))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }

            if !widget.attachments.isEmpty && !widget.answer.isEmpty {
                HStack(spacing: 4) {
                    ForEach(mediaIcons, id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.system(size: 9))
                            .foregroundColor(widget.category.color.opacity(0.6))
                    }
                }
            }

            Spacer()
        }
        .frame(width: 140, height: 90)
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Answer bottom sheet (text + photo/audio/video)

private struct AnswerSheet: View {
    let prompt: PromptItem
    @Binding var draft: String
    @Binding var draftAttachments: [MediaAttachment]
    let onSave: (String, [MediaAttachment]) -> Void
    let onCancel: () -> Void

    @FocusState private var focused: Bool
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showFilePicker = false
    @State private var showSizeAlert = false

    private var charCount: Int { draft.count }
    private var canSave: Bool {
        !draft.trimmingCharacters(in: .whitespaces).isEmpty || !draftAttachments.isEmpty
    }

    private var photoCount: Int { draftAttachments.filter { $0.type == .image }.count }
    private var videoCount: Int { draftAttachments.filter { $0.type == .video }.count }
    private var audioCount: Int { draftAttachments.filter { $0.type == .audio }.count }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.appGreige)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            // Category + question header card
            VStack(alignment: .leading, spacing: 6) {
                Text(prompt.category.rawValue.uppercased())
                    .font(.custom("HKGrotesk-SemiBold", size: 10))
                    .foregroundColor(.white.opacity(0.8))
                    .kerning(0.8)
                Text(prompt.question)
                    .font(.custom("HKGrotesk-Bold", size: 18))
                    .foregroundColor(.white)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(prompt.category.color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    // Text area
                    ZStack(alignment: .topLeading) {
                        if draft.isEmpty {
                            Text("Write what comes to mind... (or skip and use media below)")
                                .font(.custom("HKGrotesk-Regular", size: 15))
                                .foregroundColor(.appBrown.opacity(0.3))
                                .padding(.top, 4)
                                .padding(.leading, 1)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $draft)
                            .font(.custom("HKGrotesk-Regular", size: 15))
                            .foregroundColor(.appBrown)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 110)
                            .focused($focused)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    )
                    .padding(.horizontal, 20)
                    .overlay(alignment: .bottomTrailing) {
                        Text("\(charCount) chars")
                            .font(.custom("HKGrotesk-Regular", size: 11))
                            .foregroundColor(.appBrown.opacity(0.3))
                            .padding(.trailing, 28)
                            .padding(.bottom, 8)
                    }

                    // ── Media bar ──────────────────────────────────────
                    mediaBar
                        .padding(.horizontal, 20)

                    // ── Attachment thumbnails ──────────────────────────
                    if !draftAttachments.isEmpty {
                        attachmentsGrid
                            .padding(.horizontal, 20)
                    }

                    Color.clear.frame(height: 8)
                }
            }

            Spacer()

            // Buttons
            HStack(spacing: 12) {
                Button("Cancel") { onCancel() }
                    .font(.custom("HKGrotesk-Regular", size: 16))
                    .foregroundColor(.appBrown.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appOffWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .buttonStyle(.plain)

                Button {
                    onSave(draft, draftAttachments)
                } label: {
                    HStack(spacing: 6) {
                        Text("Add to impression")
                            .font(.custom("HKGrotesk-SemiBold", size: 16))
                        Text("✓")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(canSave ? Color(hex: "2979D4") : Color.appGreige)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.appCream)
        .onAppear { focused = true }
        .onChange(of: selectedPhotoItems) { _, newItems in
            Task { await loadSelectedMedia(newItems) }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.audio, .mpeg4Audio, .mp3, .wav],
            allowsMultipleSelection: false
        ) { result in
            handleAudioImport(result)
        }
        .alert("File too large", isPresented: $showSizeAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Each attachment must be under 2 MB.")
        }
    }

    // MARK: - Media Bar

    private var mediaBar: some View {
        HStack(spacing: 10) {
            Text("Attach")
                .font(.custom("HKGrotesk-SemiBold", size: 12))
                .foregroundColor(.appBrown.opacity(0.5))

            // Photo
            PhotosPicker(
                selection: $selectedPhotoItems,
                maxSelectionCount: max(1, 4 - photoCount),
                matching: .images
            ) {
                mediaChip(
                    icon: "photo",
                    label: "Photo",
                    count: photoCount,
                    color: Color(hex: "3D9B7A")
                )
            }

            // Video
            PhotosPicker(
                selection: $selectedPhotoItems,
                maxSelectionCount: 1,
                matching: .videos
            ) {
                mediaChip(
                    icon: "video",
                    label: "Video",
                    count: videoCount,
                    color: Color(hex: "6B5BB8")
                )
            }

            // Audio
            Button { showFilePicker = true } label: {
                mediaChip(
                    icon: "mic",
                    label: "Audio",
                    count: audioCount,
                    color: Color(hex: "E05C7A")
                )
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    private func mediaChip(icon: String, label: String, count: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(label)
                .font(.custom("HKGrotesk-SemiBold", size: 12))
            if count > 0 {
                Text("\(count)")
                    .font(.custom("HKGrotesk-Bold", size: 10))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(color))
            }
        }
        .foregroundColor(count > 0 ? color : .appBrown.opacity(0.55))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(count > 0 ? color.opacity(0.1) : Color.appOffWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(count > 0 ? color.opacity(0.3) : Color.appGreige, lineWidth: 1)
                )
        )
    }

    // MARK: - Attachments Grid

    private var attachmentsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ], spacing: 8) {
            ForEach(draftAttachments) { attachment in
                attachmentTile(attachment)
            }
        }
    }

    @ViewBuilder
    private func attachmentTile(_ attachment: MediaAttachment) -> some View {
        ZStack(alignment: .topTrailing) {
            Group {
                switch attachment.type {
                case .image:
                    if let uiImage = UIImage(data: attachment.data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        iconTileBg(icon: "photo", color: Color(hex: "3D9B7A"))
                    }
                case .video:
                    ZStack {
                        iconTileBg(icon: "video.fill", color: Color(hex: "6B5BB8"))
                        VStack(spacing: 2) {
                            Spacer()
                            Text(attachment.formattedSize)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.bottom, 6)
                        }
                    }
                case .audio:
                    ZStack {
                        iconTileBg(icon: "waveform", color: Color(hex: "E05C7A"))
                        VStack(spacing: 2) {
                            Spacer()
                            Text(attachment.fileName)
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                                .padding(.horizontal, 4)
                                .padding(.bottom, 6)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.appGreige.opacity(0.5), lineWidth: 1)
            )

            // Remove button
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    draftAttachments.removeAll { $0.id == attachment.id }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.appBrown.opacity(0.7))
                        .frame(width: 20, height: 20)
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(x: 4, y: -4)
        }
    }

    private func iconTileBg(icon: String, color: Color) -> some View {
        ZStack {
            color.opacity(0.15)
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color.opacity(0.7))
        }
    }

    // MARK: - Media Loading

    private func loadSelectedMedia(_ items: [PhotosPickerItem]) async {
        for item in items {
            let isVideo = item.supportedContentTypes.contains(where: {
                $0.conforms(to: .movie) || $0.conforms(to: .video)
            })

            if let data = try? await item.loadTransferable(type: Data.self) {
                let attachment = MediaAttachment(
                    type: isVideo ? .video : .image,
                    data: data,
                    fileName: isVideo ? "video.mp4" : "photo.jpg"
                )
                if attachment.isOverSizeLimit {
                    await MainActor.run { showSizeAlert = true }
                } else {
                    await MainActor.run {
                        withAnimation { draftAttachments.append(attachment) }
                    }
                }
            }
        }
        await MainActor.run { selectedPhotoItems = [] }
    }

    private func handleAudioImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            if let data = try? Data(contentsOf: url) {
                let attachment = MediaAttachment(type: .audio, data: data, fileName: url.lastPathComponent)
                if attachment.isOverSizeLimit {
                    showSizeAlert = true
                } else {
                    withAnimation { draftAttachments.append(attachment) }
                }
            }
        case .failure(let error):
            print("Audio import failed: \(error.localizedDescription)")
        }
    }
}
