//
//  OnboardingView.swift
//  Find Deals Fast
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            icon: "tag.fill",
            title: "Find the Best Deals",
            description: "Discover amazing products at unbeatable prices from top retailers worldwide"
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Save Your Favorites",
            description: "Create your personal wishlist and get notified when prices drop"
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "Compare Prices",
            description: "Compare prices across multiple stores in real-time to always get the best deal"
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a2c38"), Color(hex: "fb3ef4").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color(hex: "1475e0") : Color(hex: "2f4553"))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        Button(action: {
                            userSettings.hasCompletedOnboarding = true
                        }) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "fcffff"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "1475e0"))
                                .cornerRadius(16)
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "fcffff"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "1475e0"))
                                .cornerRadius(16)
                        }
                        
                        Button(action: {
                            userSettings.hasCompletedOnboarding = true
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "1475e0"))
                .frame(height: 120)
            
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: "fcffff"))
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.system(size: 17))
                .foregroundColor(Color(hex: "fcffff").opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

