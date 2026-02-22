//
//  SignUpView.swift
//  impressionsv1
//
//  Onboarding Step 1: name + Indian mobile number → Send OTP
//

import SwiftUI
import SwiftData

struct SignUpView: View {
    @Bindable var coordinator: OnboardingCoordinator
    @Environment(UserManager.self) private var userManager
    @Environment(\.modelContext) private var modelContext

    @FocusState private var focusedField: Field?
    enum Field { case name, phone }

    private var canContinue: Bool {
        coordinator.name.trimmingCharacters(in: .whitespaces).count >= 2 &&
        coordinator.phone.count >= 10
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Brand card ──────────────────────────────────────────
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.appForestGreen)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("welcome to")
                            .font(.custom("HKGrotesk-Light", size: 14))
                            .foregroundColor(.white.opacity(0.8))

                        HStack(spacing: 6) {
                            Text("The Table")
                                .font(.custom("HKGrotesk-Bold", size: 28))
                                .foregroundColor(.white)
                            Text("🍽️")
                                .font(.system(size: 24))
                        }

                        Text("Where every meal becomes a memory worth sharing.")
                            .font(.custom("HKGrotesk-Light", size: 14))
                            .foregroundColor(.white.opacity(0.75))
                            .lineSpacing(2)
                    }
                    .padding(22)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 148)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)

                // ── Fields ──────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 20) {

                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("YOUR NAME")
                            .font(.custom("HKGrotesk-SemiBold", size: 11))
                            .foregroundColor(.appBrown.opacity(0.6))
                            .kerning(0.8)

                        TextField("e.g. Priya Sharma", text: $coordinator.name)
                            .font(.custom("HKGrotesk-Regular", size: 16))
                            .foregroundColor(.appBrown)
                            .focused($focusedField, equals: .name)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.appOffWhite)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .submitLabel(.next)
                            .onSubmit { focusedField = .phone }
                    }

                    // Phone
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MOBILE NUMBER")
                            .font(.custom("HKGrotesk-SemiBold", size: 11))
                            .foregroundColor(.appBrown.opacity(0.6))
                            .kerning(0.8)

                        HStack(spacing: 0) {
                            Text("+91")
                                .font(.custom("HKGrotesk-Regular", size: 16))
                                .foregroundColor(.appBrown.opacity(0.5))
                                .padding(.leading, 16)
                                .padding(.trailing, 8)

                            Rectangle()
                                .fill(Color.appGreige)
                                .frame(width: 1, height: 20)
                                .padding(.trailing, 12)

                            TextField("98765 43210", text: $coordinator.phone)
                                .font(.custom("HKGrotesk-Regular", size: 16))
                                .foregroundColor(.appBrown)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .phone)
                        }
                        .padding(.vertical, 14)
                        .background(Color.appOffWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)

                // ── CTA ─────────────────────────────────────────────────
                VStack(spacing: 10) {
                    Button {
                        guard canContinue else { return }
                        focusedField = nil
                        userManager.createUser(
                            name: coordinator.name.trimmingCharacters(in: .whitespaces),
                            phoneNumber: coordinator.phone,
                            context: modelContext
                        )
                        coordinator.advance()
                    } label: {
                        Text("Send OTP →")
                    }
                    .if(canContinue) { $0.primaryButton() }
                    .if(!canContinue) { $0.inactiveButton() }
                    .disabled(!canContinue)
                    .animation(.easeInOut(duration: 0.2), value: canContinue)

                    Text("By continuing you agree to our Terms & Privacy Policy")
                        .font(.custom("HKGrotesk-Light", size: 12))
                        .foregroundColor(.appBrown.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
            }
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Conditional modifier helper
extension View {
    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}
