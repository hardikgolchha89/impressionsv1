//
//  FindPeopleView.swift
//  impressionsv1
//
//  Onboarding Step 5: Find friends via contacts (or skip)
//

import SwiftUI

private struct FakeContact: Identifiable {
    let id = UUID()
    let initials: String
    let name: String
    let spots: Int
}

private let fakeContacts: [FakeContact] = [
    FakeContact(initials: "HG", name: "Hardik G",  spots: 4),
    FakeContact(initials: "MS", name: "Meera S",   spots: 12),
    FakeContact(initials: "RK", name: "Rohit K",   spots: 7),
    FakeContact(initials: "AP", name: "Ananya P",  spots: 2),
    FakeContact(initials: "VD", name: "Varun D",   spots: 9),
]

struct FindPeopleView: View {
    @Bindable var coordinator: OnboardingCoordinator
    @State private var allowedContacts = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Header ─────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("Find your people")
                            .font(.custom("HKGrotesk-Bold", size: 26))
                            .foregroundColor(.appCrimson)
                        Text("👥")
                            .font(.system(size: 22))
                    }
                    Text("See where your friends are eating. Allow access to contacts so we can match you with people you know.")
                        .font(.custom("HKGrotesk-Regular", size: 14))
                        .foregroundColor(.appBrown.opacity(0.7))
                        .lineSpacing(3)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)

                // ── Amber card — already on The Table ─────────────────
                VStack(alignment: .leading, spacing: 0) {
                    Text("ALREADY ON THE TABLE")
                        .font(.custom("HKGrotesk-SemiBold", size: 10))
                        .foregroundColor(.white.opacity(0.75))
                        .kerning(0.8)
                        .padding(.bottom, 14)

                    VStack(spacing: 0) {
                        ForEach(fakeContacts) { contact in
                            HStack(spacing: 12) {
                                // Avatar circle
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.25))
                                        .frame(width: 36, height: 36)
                                    Text(contact.initials)
                                        .font(.custom("HKGrotesk-SemiBold", size: 12))
                                        .foregroundColor(.white)
                                }

                                Text(contact.name)
                                    .font(.custom("HKGrotesk-SemiBold", size: 15))
                                    .foregroundColor(.white)

                                Spacer()

                                Text("\(contact.spots) spots")
                                    .font(.custom("HKGrotesk-Regular", size: 13))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            .padding(.bottom, contact.id == fakeContacts.last?.id ? 0 : 14)
                        }
                    }

                    Text("+ many more waiting for you")
                        .font(.custom("HKGrotesk-Light", size: 12))
                        .foregroundColor(.white.opacity(0.65))
                        .padding(.top, 14)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.appAmber)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // ── Contacts permission toggle ─────────────────────────
                Button {
                    withAnimation(.spring(duration: 0.2)) { allowedContacts.toggle() }
                } label: {
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(allowedContacts ? Color.appOlive : Color.appOffWhite)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .stroke(allowedContacts ? Color.appOlive : Color.appGreige, lineWidth: 1)
                                )
                            if allowedContacts {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Allow The Table to access my contacts to find friends.")
                                .font(.custom("HKGrotesk-SemiBold", size: 14))
                                .foregroundColor(.appBrown)
                            Text("Your contacts are never stored on our servers.")
                                .font(.custom("HKGrotesk-Regular", size: 12))
                                .foregroundColor(.appBrown.opacity(0.55))
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.appOffWhite)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // ── CTAs ──────────────────────────────────────────────
                VStack(spacing: 12) {
                    Button {
                        coordinator.advance()
                    } label: {
                        Text("Allow & Find Friends →")
                    }
                    .if(allowedContacts) { $0.primaryButton() }
                    .if(!allowedContacts) { $0.inactiveButton() }
                    .animation(.easeInOut(duration: 0.2), value: allowedContacts)

                    Button {
                        coordinator.advance()
                    } label: {
                        Text("Skip for now")
                            .font(.custom("HKGrotesk-Regular", size: 14))
                            .foregroundColor(.appBrown.opacity(0.55))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}
