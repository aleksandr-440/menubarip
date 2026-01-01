//
//  IPService.swift
//  MenuBarIP
//
//  Created on macOS
//

import Foundation

class IPService {
    static let shared = IPService()
    
    private let session: URLSession
    private let timeout: TimeInterval = 10.0
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        self.session = URLSession(configuration: config)
    }
    
    func fetchIPInfo() async -> [APIResult] {
        async let ipifyResult = fetchFromIPify()
        async let ipapiResult = fetchFromIPAPI()
        async let ipinfoResult = fetchFromIPInfo()
        
        return await [ipifyResult, ipapiResult, ipinfoResult]
    }
    
    private func fetchFromIPify() async -> APIResult {
        guard let url = URL(string: "https://api.ipify.org/?format=json") else {
            return APIResult(source: "ipify", error: URLError(.badURL))
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(IPResponse.self, from: data)
            return APIResult(ip: response.ip, source: "ipify")
        } catch {
            return APIResult(source: "ipify", error: error)
        }
    }
    
    private func fetchFromIPAPI() async -> APIResult {
        guard let url = URL(string: "https://ipapi.co/json/") else {
            return APIResult(source: "ipapi", error: URLError(.badURL))
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(IPResponse.self, from: data)
            return APIResult(ip: response.ip, countryCode: response.countryCode, countryName: response.countryName, source: "ipapi")
        } catch {
            return APIResult(source: "ipapi", error: error)
        }
    }
    
    private func fetchFromIPInfo() async -> APIResult {
        guard let url = URL(string: "https://ipinfo.io/json") else {
            return APIResult(source: "ipinfo", error: URLError(.badURL))
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(IPResponse.self, from: data)
            // ipinfo.io uses "country" field, not "country_code"
            let countryCode = response.country
            // Convert country code to full name using Locale
            let countryName: String? = countryCode.flatMap { code in
                Locale(identifier: "en_US").localizedString(forRegionCode: code)
            }
            return APIResult(ip: response.ip, countryCode: countryCode, countryName: countryName, source: "ipinfo")
        } catch {
            return APIResult(source: "ipinfo", error: error)
        }
    }
}

