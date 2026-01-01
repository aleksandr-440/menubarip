//
//  QuorumResolver.swift
//  MenuBarIP
//
//  Created on macOS
//

import Foundation

struct QuorumResolver {
    static func resolve(results: [APIResult]) -> ResolvedIP? {
        // Filter out results with errors or missing IP
        let validResults = results.filter { $0.error == nil && $0.ip != nil }
        
        guard !validResults.isEmpty else {
            return nil
        }
        
        // Extract IPv4 addresses only
        let ipv4Results = validResults.compactMap { result -> APIResult? in
            guard let ip = result.ip, isIPv4(ip) else { return nil }
            return result
        }
        
        guard !ipv4Results.isEmpty else {
            return nil
        }
        
        // Find IP by majority (2 out of 3)
        let ipCounts = Dictionary(grouping: ipv4Results, by: { $0.ip! })
            .mapValues { $0.count }
        
        guard let mostCommonIP = ipCounts.max(by: { $0.value < $1.value }),
              mostCommonIP.value >= 2 || ipv4Results.count == 1 else {
            return nil
        }
        
        let resolvedIP = mostCommonIP.key
        
        // Find country code and name by majority for results with this IP
        let matchingResults = ipv4Results.filter { $0.ip == resolvedIP }
        let countryCodes = matchingResults.compactMap { $0.countryCode }
        
        let countryCode: String?
        if !countryCodes.isEmpty {
            let countryCounts = Dictionary(grouping: countryCodes, by: { $0 })
                .mapValues { $0.count }
            
            if let mostCommonCountry = countryCounts.max(by: { $0.value < $1.value }),
               mostCommonCountry.value >= 2 || countryCodes.count == 1 {
                countryCode = mostCommonCountry.key
            } else {
                countryCode = nil
            }
        } else {
            countryCode = nil
        }
        
        // Find country name by majority, or convert from code if needed
        let countryNames = matchingResults.compactMap { $0.countryName }
        let countryName: String?
        if !countryNames.isEmpty {
            let nameCounts = Dictionary(grouping: countryNames, by: { $0 })
                .mapValues { $0.count }
            
            if let mostCommonName = nameCounts.max(by: { $0.value < $1.value }),
               mostCommonName.value >= 2 || countryNames.count == 1 {
                countryName = mostCommonName.key
            } else {
                // Fallback: convert country code to name if available
                countryName = countryCode.flatMap { code in
                    Locale(identifier: "en_US").localizedString(forRegionCode: code)
                }
            }
        } else {
            // Fallback: convert country code to name if available
            countryName = countryCode.flatMap { code in
                Locale(identifier: "en_US").localizedString(forRegionCode: code)
            }
        }
        
        let flag = CountryFlagMapper.flag(for: countryCode)
        
        return ResolvedIP(ip: resolvedIP, countryCode: countryCode, countryName: countryName, flag: flag)
    }
    
    private static func isIPv4(_ ip: String) -> Bool {
        let parts = ip.split(separator: ".")
        guard parts.count == 4 else { return false }
        
        return parts.allSatisfy { part in
            guard let num = Int(part), num >= 0, num <= 255 else { return false }
            return true
        }
    }
}

