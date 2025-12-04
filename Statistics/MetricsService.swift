//
//  MetricsService.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/25/25.
//

import Foundation

// MARK: - Protocol

protocol MetricsServiceProtocol {
    func track(_ event: MetricsEvent)
}

// MARK: - Events

enum MetricsEvent {
    case statisticsScreenOpen
    case statisticsSortByName
    case statisticsSortByRating
    case statisticsUserTap(userId: String)

    case userCollectionScreenOpen
    case userCollectionNftTap(nftId: String)
}

extension MetricsEvent {
    var name: String {
        switch self {
        case .statisticsScreenOpen:
            return "statistics_screen_open"
        case .statisticsSortByName:
            return "statistics_sort_by_name"
        case .statisticsSortByRating:
            return "statistics_sort_by_rating"
        case .statisticsUserTap:
            return "statistics_user_tap"
        case .userCollectionScreenOpen:
            return "user_collection_screen_open"
        case .userCollectionNftTap:
            return "user_collection_nft_tap"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .statisticsUserTap(let userId):
            return ["user_id": userId]
        case .userCollectionNftTap(let nftId):
            return ["nft_id": nftId]
        default:
            return nil
        }
    }
}

// MARK: - Service

final class MetricsService: MetricsServiceProtocol {
    static let shared = MetricsService()
    private init() {}

    
    func setup() {
        
        print("MetricsService setup called")
    }

    func track(_ event: MetricsEvent) {
        if let params = event.parameters {
            print("METRICS EVENT:", event.name, params)
        } else {
            print("METRICS EVENT:", event.name)
        }
    }
}
