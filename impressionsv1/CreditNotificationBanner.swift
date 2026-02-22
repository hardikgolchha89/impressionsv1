//
//  CreditNotificationBanner.swift
//  impressionsv1
//
//  Slim top-of-screen banner shown to the impression owner when someone
//  credits their impression. Auto-dismisses after 4 seconds.
//

import SwiftUI

struct CreditNotificationBanner: View {
    let message: String
    let onDismiss: () -> Void

    @State private var timer: Timer? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.appPink)

            Text(message)
                .font(.custom("HKGrotesk-SemiBold", size: 13))
                .foregroundColor(.appDarkText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appGrayText)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        )
        .padding(.horizontal, Spacing.md)
        .padding(.top, 8) // Sits below the status bar
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            dismiss()
        }
    }

    private func dismiss() {
        timer?.invalidate()
        withAnimation(.spring(duration: 0.3)) {
            onDismiss()
        }
    }
}

#Preview {
    VStack {
        CreditNotificationBanner(
            message: "Pallavi took your rec for Bombay Canteen.",
            onDismiss: {}
        )
        Spacer()
    }
    .background(Color(hex: "F5F5F5"))
}
