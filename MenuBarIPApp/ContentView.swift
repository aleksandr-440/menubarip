//
//  ContentView.swift
//  MenuBarIP
//
//  Created on macOS
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: IPViewModel
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let ip = viewModel.resolvedIP {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(localizationManager.localizedString(.ipAddress))
                            .font(.headline)
                        Spacer()
                        Text(ip.ip)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    if !viewModel.disableCountryLookup {
                        if let countryName = ip.countryName {
                            HStack {
                                Text(localizationManager.localizedString(.country))
                                    .font(.headline)
                                Spacer()
                                Text("\(ip.flag) \(countryName)")
                                    .font(.body)
                            }
                        } else if let countryCode = ip.countryCode {
                            HStack {
                                Text(localizationManager.localizedString(.country))
                                    .font(.headline)
                                Spacer()
                                Text("\(ip.flag) \(countryCode)")
                                    .font(.body)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.top)
            }
            
            Divider()
                .padding(.top, 4)
                .padding(.bottom, 4)
            
            HStack {
                Button(action: {
                    Task {
                        await viewModel.refresh(force: true)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                            .animation(viewModel.isLoading ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
                            .frame(width: 16, height: 16)
                        Text(localizationManager.localizedString(.refresh))
                    }
                }
                .disabled(viewModel.isLoading)
                
                Spacer()
                
                Button(localizationManager.localizedString(.exit)) {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.top, 4)
                .padding(.bottom, 4)
            
            Toggle(localizationManager.localizedString(.showIP), isOn: $viewModel.showIPInStatusBar)
                .toggleStyle(.switch)
                .disabled(viewModel.disableCountryLookup)
                .padding(.horizontal)
            
            Divider()
                .padding(.top, 4)
                .padding(.bottom, 4)
            
            Toggle(localizationManager.localizedString(.disableCountry), isOn: $viewModel.disableCountryLookup)
                .toggleStyle(.switch)
                .padding(.horizontal)
            
            Divider()
                .padding(.top, 4)
                .padding(.bottom, 4)
            
            HStack {
                Text(localizationManager.localizedString(.language))
                    .font(.caption)
                Spacer()
                Picker("", selection: $localizationManager.currentLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .frame(width: 250)
    }
}

