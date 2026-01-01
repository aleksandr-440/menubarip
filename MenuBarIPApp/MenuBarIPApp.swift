//
//  MenuBarIPApp.swift
//  MenuBarIP
//
//  Created on macOS
//

import SwiftUI

@main
struct MenuBarIPApp: App {
    @StateObject private var ipViewModel = IPViewModel()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(ipViewModel)
        } label: {
            Text(ipViewModel.statusBarText)
        }
        .menuBarExtraStyle(.window)
    }
}

