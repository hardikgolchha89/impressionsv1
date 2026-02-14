//
//  ContentView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showCreateFlow = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main ScrollView with feed content
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        VStack(alignment: .leading, spacing: 4) {
                            // Greeting
                            Text("Hello Taashi!")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.appDarkText)
                            
                            // Prompt + Action Button
                            HStack {
                                Text("Been anywhere new?")
                                    .font(.system(size: 22, weight: .regular))
                                    .foregroundColor(.appDarkText)
                                
                                Spacer()
                                
                                Button(action: {
                                    // Placeholder action
                                }) {
                                    Text("Share your\nImpression")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.appDarkText)
                                        .multilineTextAlignment(.trailing)
                                        .padding(.top, 4)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.xl)
                        .padding(.bottom, Spacing.xl)
                        
                        // Cards Section
                        VStack(spacing: Spacing.lg) {
                            ForEach(MockData.allImpressions) { impression in
                                FeedCardView(impression: impression)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, 120) // Space for bottom nav
                    }
                }
                .background(Color(hex: "F5F5F5"))
                
                // Bottom Navigation Overlay
                VStack {
                    Spacer()
                    
                    HStack(spacing: 40) {
                        // Icon 1 - Discover
                        Button(action: {
                            // Placeholder action
                        }) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        
                        // Icon 2 - Add (center, larger)
                        Button(action: {
                            showCreateFlow = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.red)
                        }
                        
                        // Icon 3 - Map
                        Button(action: {
                            // Placeholder action
                        }) {
                            Image(systemName: "map")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreateFlow) {
                CreateImpressionFlowView()
            }
        }
    }
}

#Preview {
    ContentView()
}
