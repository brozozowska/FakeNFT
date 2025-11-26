//
//  MetricsService.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/25/25.
//

import Foundation
import YandexMobileMetrica

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

    var parameters: [AnyHashable: Any]? {
        switch self {
        case .statisticsScreenOpen:
            return nil

        case .statisticsSortByName:
            return ["sort_option": "name"]

        case .statisticsSortByRating:
            return ["sort_option": "rating"]

        case let .statisticsUserTap(userId):
            return ["user_id": userId]

        case .userCollectionScreenOpen:
            return nil

        case let .userCollectionNftTap(nftId):
            return ["nft_id": nftId]
        }
    }
}

// MARK: - Protocol

protocol MetricsServiceProtocol: AnyObject {
    func setup()
    func track(_ event: MetricsEvent)
}

// MARK: - Implementation

final class MetricsService: MetricsServiceProtocol {

    static let shared = MetricsService()

    private init() {}

    func setup() {
        let apiKey = "YOUR_APPMETRICA_API_KEY"

        guard let configuration = YMMYandexMetricaConfiguration(apiKey: apiKey) else {
            print("MetricsService: failed to create configuration")
            return
        }

        YMMYandexMetrica.activate(with: configuration)
        print("MetricsService: AppMetrica activated")
    }

    func track(_ event: MetricsEvent) {
        YMMYandexMetrica.reportEvent(
            event.name,
            parameters: event.parameters
        ) { error in
            print("MetricsService: failed to report event \(event.name), error: \(error.localizedDescription)")
        }
    }
}

