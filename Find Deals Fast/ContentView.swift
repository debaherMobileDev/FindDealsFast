//
//  ContentView.swift
//  Find Deals Fast
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userSettings = UserSettings()
    
    var body: some View {
        Group {
            if userSettings.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(userSettings)
            } else {
                OnboardingView()
                    .environmentObject(userSettings)
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            WishlistView()
                .tabItem {
                    Label("Wishlist", systemImage: "heart.fill")
                }
                .badge(userSettings.wishlist.count)
        }
        .accentColor(Color(hex: "1475e0"))
    }
}

#Preview {
    ContentView()
}
