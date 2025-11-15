//
//  SortPreferences.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import Foundation

enum StatisticsSort: String {
    case byName
    case byRating
}

private enum DefaultsKey {
    static let statisticsSort = "statistics.sort"
}

struct SortPreferences {
    private let defaults: UserDefaults = .standard

    var statisticsSort: StatisticsSort {
        get {
            guard let raw = defaults.string(forKey: DefaultsKey.statisticsSort),
                  let v = StatisticsSort(rawValue: raw) else { return .byRating } // по ТЗ
            return v
        }
        set { defaults.set(newValue.rawValue, forKey: DefaultsKey.statisticsSort) }
    }
}
