//
//  FoodOrderView.swift
//  impressionsv1
//
//  "What did you order?" — receipt-style text entry, one dish per line.
//

import SwiftUI

struct FoodOrderView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var orderText: String = ""
    @FocusState private var focused: Bool

    private var place: Place { coordinator.data.place ?? Place(id: "", name: "the place", location: nil, cuisine: nil) }

    private var dishes: [String] {
        orderText
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private var hasContent: Bool { !dishes.isEmpty }

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

                    Text("NEW IMPRESSION")
                        .font(.custom("HKGrotesk-SemiBold", size: 11))
                        .foregroundColor(.appBrown.opacity(0.5))
                        .kerning(0.8)

                    Spacer()
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Heading ────────────────────────────────────
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Text("What did you order?")
                                    .font(.custom("HKGrotesk-Bold", size: 26))
                                    .foregroundColor(.appBrown)
                                Text("🥡")
                                    .font(.system(size: 22))
                            }
                            Text("The dishes you actually had — your friends will want to know.")
                                .font(.custom("HKGrotesk-Regular", size: 14))
                                .foregroundColor(.appBrown.opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 20)

                        // ── Receipt card ───────────────────────────────
                        VStack(alignment: .leading, spacing: 0) {
                            // Amber header
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ORDER RECEIPT")
                                    .font(.custom("HKGrotesk-SemiBold", size: 10))
                                    .foregroundColor(.white.opacity(0.75))
                                    .kerning(0.8)
                                Text(place.name)
                                    .font(.custom("HKGrotesk-Bold", size: 16))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(Color.appAmber)

                            // Text entry — italic/handwriting feel
                            ZStack(alignment: .topLeading) {
                                if orderText.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(["Lamb rogan josh", "Pindi ghee dara", "Vada pav to start", "The mango kulfi at the end..."], id: \.self) { hint in
                                            Text(hint)
                                                .font(.custom("HKGrotesk-LightItalic", size: 15))
                                                .foregroundColor(.appBrown.opacity(0.28))
                                        }
                                    }
                                    .allowsHitTesting(false)
                                }
                                TextEditor(text: $orderText)
                                    .font(.custom("HKGrotesk-LightItalic", size: 15))
                                    .foregroundColor(.appBrown)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(minHeight: 180)
                                    .focused($focused)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(Color.white)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }

            // ── Bottom CTA ─────────────────────────────────────────────
            VStack(spacing: 0) {
                if hasContent {
                    Button {
                        focused = false
                        coordinator.completeFoodOrder(dishes: dishes)
                    } label: { Text("Looks good →") }
                    .primaryButton()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                } else {
                    Button {
                        focused = false
                        coordinator.completeFoodOrder(dishes: [])
                    } label: {
                        Text("Skip for now →")
                            .font(.custom("HKGrotesk-SemiBold", size: 17))
                            .foregroundColor(.appBrown.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
            }
            .background(Color.appCream)
            .animation(.easeInOut(duration: 0.2), value: hasContent)
        }
    }
}
