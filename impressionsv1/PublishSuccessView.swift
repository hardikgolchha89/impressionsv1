//
//  PublishSuccessView.swift
//  impressionsv1
//
//  Full-screen success state after publishing. Auto-dismisses to feed.
//

import SwiftUI

struct PublishSuccessView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator

    private var placeName: String {
        coordinator.data.place?.name ?? "Your impression"
    }

    var body: some View {
        ZStack {
            Color.appCream.ignoresSafeArea()

            VStack {
                Spacer()

                // Party popper
                Text("🎉")
                    .font(.system(size: 56))
                    .padding(.bottom, 16)

                // Forest green card
                VStack(spacing: 10) {
                    Text("Impression posted!")
                        .font(.custom("HKGrotesk-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.75))

                    Text("\(placeName) is now on your feed ✓")
                        .font(.custom("HKGrotesk-Bold", size: 22))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Your friends can now see exactly what you thought.\nThe honest stuff only you would say.")
                        .font(.custom("HKGrotesk-Light", size: 14))
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.appForestGreen)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                Spacer().frame(height: 20)

                Text("Returning to feed...")
                    .font(.custom("HKGrotesk-Light", size: 13))
                    .foregroundColor(.appBrown.opacity(0.4))

                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                coordinator.finishAndDismiss()
            }
        }
    }
}
