//
//  ImpressionPreviewView.swift
//  impressionsv1
//
//  "Looking good! 👀" — preview card before publishing.
//

import SwiftUI

struct ImpressionPreviewView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var publishing = false

    private var data: ImpressionData { coordinator.data }
    private var place: Place { data.place ?? Place(id: "", name: "Unknown", location: nil, cuisine: nil) }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appCream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // ── Top bar ────────────────────────────────────────────
                HStack {
                    Button { coordinator.goBack() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appBrown)
                            .frame(width: 44, height: 44)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("PREVIEW")
                            .font(.custom("HKGrotesk-SemiBold", size: 11))
                            .foregroundColor(.appOlive)
                            .kerning(0.8)
                    }

                    Spacer()

                    // Full progress
                    HStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.appOlive)
                                .frame(height: 4)
                        }
                    }
                    .frame(width: 60)
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text("Looking good!")
                                    .font(.custom("HKGrotesk-Bold", size: 26))
                                    .foregroundColor(.appBrown)
                                Text("👀")
                                    .font(.system(size: 22))
                            }
                            Text("Here's how your impression will appear on the feed.")
                                .font(.custom("HKGrotesk-Regular", size: 14))
                                .foregroundColor(.appBrown.opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 20)

                        // ── Feed card preview ──────────────────────────
                        VStack(alignment: .leading, spacing: 0) {

                            // Author row
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.appAmber.opacity(0.5))
                                        .frame(width: 36, height: 36)
                                    Text("Y")
                                        .font(.custom("HKGrotesk-SemiBold", size: 15))
                                        .foregroundColor(.white)
                                }
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("You")
                                        .font(.custom("HKGrotesk-SemiBold", size: 14))
                                        .foregroundColor(.appBrown)
                                    Text("Just now")
                                        .font(.custom("HKGrotesk-Regular", size: 11))
                                        .foregroundColor(.appBrown.opacity(0.45))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 12)

                            // Place + tags
                            VStack(alignment: .leading, spacing: 8) {
                                Text(place.name)
                                    .font(.custom("HKGrotesk-Bold", size: 20))
                                    .foregroundColor(.appBrown)

                                HStack(spacing: 6) {
                                    ForEach([data.occasion, data.groupSize, data.companions].filter { !$0.isEmpty }, id: \.self) { tag in
                                        Text(tag)
                                            .font(.custom("HKGrotesk-Regular", size: 11))
                                            .foregroundColor(.appBrown.opacity(0.7))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Capsule().fill(Color.appOffWhite))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                            Divider().background(Color.appBrown.opacity(0.08))

                            // Widget answer cards — 2 column grid
                            let answered = coordinator.data.widgetAnswers
                            if !answered.isEmpty {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(answered.prefix(4)) { wa in
                                        PreviewWidgetCard(widget: wa)
                                    }
                                }
                                .padding(14)
                            }

                            // Dishes row
                            if !data.dishes.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("FOOD")
                                        .font(.custom("HKGrotesk-SemiBold", size: 9))
                                        .foregroundColor(.appAmber)
                                        .kerning(0.6)
                                    Text(data.dishes.prefix(3).joined(separator: " · "))
                                        .font(.custom("HKGrotesk-Regular", size: 12))
                                        .foregroundColor(.appBrown.opacity(0.75))
                                        .lineLimit(2)
                                }
                                .padding(.horizontal, 14)
                                .padding(.bottom, 16)
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.07), radius: 10, y: 4)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }

            // ── Bottom CTAs ────────────────────────────────────────────
            VStack(spacing: 8) {
                Button {
                    publishing = true
                    coordinator.publish()
                } label: {
                    HStack(spacing: 6) {
                        Text(publishing ? "Publishing..." : "Publish impression")
                        if !publishing { Text("🚀").font(.system(size: 16)) }
                    }
                }
                .primaryButton()
                .disabled(publishing)
                .padding(.horizontal, 20)

                Button { coordinator.goBack() } label: {
                    Text("← Edit widgets")
                        .font(.custom("HKGrotesk-Regular", size: 14))
                        .foregroundColor(.appBrown.opacity(0.5))
                }
                .padding(.bottom, 8)
            }
            .padding(.vertical, 12)
            .background(Color.appCream)
        }
    }
}

// MARK: - Preview widget card

private struct PreviewWidgetCard: View {
    let widget: WidgetAnswer

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(widget.category.rawValue.uppercased())
                .font(.custom("HKGrotesk-SemiBold", size: 9))
                .foregroundColor(widget.category.color)
                .kerning(0.5)
            Text(widget.answer)
                .font(.custom("HKGrotesk-Regular", size: 11))
                .foregroundColor(.appBrown.opacity(0.8))
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
        .padding(10)
        .background(widget.category.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
