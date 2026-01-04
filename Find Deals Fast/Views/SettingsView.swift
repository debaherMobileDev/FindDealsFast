//
//  SettingsView.swift
//  Find Deals Fast
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            Color(hex: "1a2c38")
                .ignoresSafeArea()
            
            Form {
                // Preferences Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preferred Currency")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                        
                        Picker("Currency", selection: $userSettings.preferredCurrency) {
                            Text("USD").tag("USD")
                            Text("EUR").tag("EUR")
                            Text("GBP").tag("GBP")
                            Text("JPY").tag("JPY")
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowBackground(Color(hex: "2f4553"))
                } header: {
                    Text("Preferences")
                        .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                }
                
                // Notifications Section
                Section {
                    Toggle("Price Drop Notifications", isOn: $userSettings.enableNotifications)
                        .foregroundColor(Color(hex: "fcffff"))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Price Alert Threshold")
                                .foregroundColor(Color(hex: "fcffff"))
                            Spacer()
                            Text("\(Int(userSettings.priceAlertThreshold))%")
                                .foregroundColor(Color(hex: "1475e0"))
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Slider(value: $userSettings.priceAlertThreshold, in: 5...50, step: 5)
                            .tint(Color(hex: "1475e0"))
                        
                        Text("Get notified when prices drop by this percentage")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "fcffff").opacity(0.6))
                    }
                    .disabled(!userSettings.enableNotifications)
                    .opacity(userSettings.enableNotifications ? 1 : 0.5)
                    .listRowBackground(Color(hex: "2f4553"))
                } header: {
                    Text("Notifications")
                        .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(Color(hex: "fcffff"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(Color(hex: "fcffff").opacity(0.6))
                    }
                    .listRowBackground(Color(hex: "2f4553"))
                    
                    HStack {
                        Text("Wishlist Items")
                            .foregroundColor(Color(hex: "fcffff"))
                        Spacer()
                        Text("\(userSettings.wishlist.count)")
                            .foregroundColor(Color(hex: "1475e0"))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .listRowBackground(Color(hex: "2f4553"))
                } header: {
                    Text("About")
                        .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                }
                
                // Account Section
                Section {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Reset App & Delete All Data")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color(hex: "2f4553"))
                } header: {
                    Text("Account")
                        .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                } footer: {
                    Text("This will reset the app to its initial state and clear all your data including wishlist items.")
                        .foregroundColor(Color(hex: "fcffff").opacity(0.5))
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset App?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                userSettings.resetApp()
                dismiss()
            }
        } message: {
            Text("This will delete all your data and reset the app to the onboarding screen. This action cannot be undone.")
        }
    }
}

