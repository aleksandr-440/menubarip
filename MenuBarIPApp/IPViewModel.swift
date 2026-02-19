//
//  IPViewModel.swift
//  MenuBarIP
//
//  Created on macOS
//

import Combine
import Foundation
import SwiftUI
import Network

class IPViewModel: ObservableObject {
    @Published var resolvedIP: ResolvedIP?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var statusBarText: String = "Loading..."
    @Published var showIPInStatusBar: Bool {
        didSet {
            UserDefaults.standard.set(showIPInStatusBar, forKey: "showIPInStatusBar")
            updateStatusBarText()
        }
    }
    
    private let ipService = IPService.shared
    private let cacheManager = CacheManager.shared
    private var refreshTimer: Timer?
    private var networkMonitor: NWPathMonitor?
    private var monitorQueue: DispatchQueue?
    
    var localizationManager = LocalizationManager.shared
    
    init() {
        self.showIPInStatusBar = UserDefaults.standard.object(forKey: "showIPInStatusBar") as? Bool ?? true
        loadInitialData()
        setupHourlyRefresh()
        setupNetworkMonitoring()
    }
    
    @MainActor
    func loadInitialData() {
        // Try to load from cache first
        if let cached = cacheManager.getCached() {
            resolvedIP = cached
            updateStatusBarText()
        } else {
            Task { @MainActor in
                await refresh(force: true)
            }
        }
    }
    
    @MainActor
    func refresh(force: Bool = false) async {
        // Check cache if not forcing
        if !force, let cached = cacheManager.getCached() {
            resolvedIP = cached
            updateStatusBarText()
            return
        }
        
        isLoading = true
        errorMessage = nil
        updateStatusBarText(showLoading: true)
        
        let results = await ipService.fetchIPInfo()
        
        if let resolved = QuorumResolver.resolve(results: results) {
            resolvedIP = resolved
            cacheManager.setCache(resolved)
            errorMessage = nil
        } else {
            // Try to use cached value if available
            if let cached = cacheManager.getCached() {
                resolvedIP = cached
            } else {
                errorMessage = localizationManager.localizedString(.errorMessage)
            }
        }
        
        isLoading = false
        updateStatusBarText()
    }
    
    @MainActor
    private func updateStatusBarText(showLoading: Bool = false) {
        if showLoading {
            statusBarText = "🔄"
        } else if let ip = resolvedIP {
            statusBarText = "\(ip.ip) \(ip.flag)"
        } else {
            statusBarText = "🏴‍☠️"
        }
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor = NWPathMonitor()
        monitorQueue = DispatchQueue(label: "NetworkMonitor")
        
        guard let monitor = networkMonitor, let queue = monitorQueue else { return }
        
        monitor.pathUpdateHandler = { [weak self] path in
            // Only refresh if network becomes available (not when it goes down)
            if path.status == .satisfied {
                Task { @MainActor [weak self] in
                    // Small delay to ensure network is stable
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    await self?.refresh(force: true)
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func setupHourlyRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refresh(force: true)
            }
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
        networkMonitor?.cancel()
    }
}

