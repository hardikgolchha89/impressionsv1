//
//  OTPView.swift
//  impressionsv1
//
//  Onboarding Step 2: 6-digit OTP boxes
//

import SwiftUI

struct OTPView: View {
    @Bindable var coordinator: OnboardingCoordinator
    @State private var digits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?

    private var otpCode: String { digits.joined() }
    private var canVerify: Bool { otpCode.count == 6 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Back
            Button { coordinator.goBack() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 13, weight: .medium))
                    Text("Back")
                        .font(.custom("HKGrotesk-Regular", size: 14))
                }
                .foregroundColor(.appBrown)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 28)

            // Heading
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("Enter the code")
                        .font(.custom("HKGrotesk-Bold", size: 28))
                        .foregroundColor(.appCrimson)
                    Text("✉️")
                        .font(.system(size: 24))
                }

                Text("We sent a 6-digit OTP to +91 \(maskedPhone)")
                    .font(.custom("HKGrotesk-Regular", size: 15))
                    .foregroundColor(.appBrown.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)

            // ── 6 digit boxes ──────────────────────────────────────────
            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { i in
                    OTPDigitBox(
                        digit: $digits[i],
                        isFocused: focusedIndex == i
                    )
                    .focused($focusedIndex, equals: i)
                    .onChange(of: digits[i]) { _, new in
                        let filtered = new.filter(\.isNumber)
                        if filtered.count > 1 {
                            // Pasted — distribute across boxes
                            let chars = Array(filtered)
                            for j in 0..<min(chars.count, 6) {
                                digits[j] = String(chars[j])
                            }
                            focusedIndex = min(chars.count, 5)
                        } else {
                            digits[i] = String(filtered.prefix(1))
                            if !filtered.isEmpty && i < 5 {
                                focusedIndex = i + 1
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            // ── CTA ───────────────────────────────────────────────────
            VStack(spacing: 14) {
                Button {
                    guard canVerify else { return }
                    // In production: validate OTP with backend.
                    // For now, any 6-digit code proceeds.
                    focusedIndex = nil
                    coordinator.advance()
                } label: {
                    Text("Verify & Continue →")
                }
                .if(canVerify) { $0.primaryButton() }
                .if(!canVerify) { $0.inactiveButton() }
                .disabled(!canVerify)
                .animation(.easeInOut(duration: 0.2), value: canVerify)
                .padding(.horizontal, 20)

                HStack(spacing: 4) {
                    Text("Didn't receive it?")
                        .font(.custom("HKGrotesk-Regular", size: 13))
                        .foregroundColor(.appBrown.opacity(0.6))
                    Button("Resend OTP") { /* TODO: resend */ }
                        .font(.custom("HKGrotesk-SemiBold", size: 13))
                        .foregroundColor(.appCrimson)
                }
            }

            Spacer()
        }
        .onAppear { focusedIndex = 0 }
    }

    private var maskedPhone: String {
        let p = coordinator.phone
        guard p.count >= 4 else { return p }
        return p.prefix(p.count - 4) + "••••"
    }
}

// MARK: - Single digit box

private struct OTPDigitBox: View {
    @Binding var digit: String
    let isFocused: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.appOffWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isFocused ? Color.appOlive : Color.appGreige, lineWidth: isFocused ? 1.5 : 1)
                )

            Text(digit)
                .font(.custom("HKGrotesk-SemiBold", size: 22))
                .foregroundColor(.appBrown)
        }
        .frame(height: 56)
        // Invisible text field driving input
        .overlay(
            TextField("", text: $digit)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .opacity(0.01)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
}
