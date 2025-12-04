//
//  StatisticsViewModel.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import Foundation

final class StatisticsViewModel {

    var onLoading: ((Bool) -> Void)?
    var onUsers: (([User]) -> Void)?
    var onError: ((ErrorModel) -> Void)?

    private let service: UsersService
    private var prefs: SortPreferences
    private(set) var users: [User] = []

    init(service: UsersService, prefs: SortPreferences = SortPreferences()) {
        self.service = service
        self.prefs = prefs
    }

    var currentSort: StatisticsSort {
        get { prefs.statisticsSort }
        set { prefs.statisticsSort = newValue }
    }

    func load() {
        print("🟡 StatisticsViewModel.loadUsers() called")
        
        onLoading?(true)
        service.loadUsers { [weak self] result in
            print("🟡 service.loadUsers completion called with result:", result)
            
            guard let self else { return }
            self.onLoading?(false)
            switch result {
            case .success(let list):
                let sorted = self.sortedUsers(list, by: self.currentSort)
                self.users = sorted
                self.onUsers?(sorted)
            case .failure:
                let error = ErrorModel(
                    message: "Не удалось загрузить рейтинг",
                    actionText: "Повторить",
                    action: { [weak self] in self?.load() }
                )
                self.onError?(error)
            }
        }
    }

    func changeSort(to sort: StatisticsSort) {
        currentSort = sort
        users = sortedUsers(users, by: sort)
        onUsers?(users)
    }

    private func sortedUsers(_ items: [User], by sort: StatisticsSort) -> [User] {
        switch sort {
        case .byName:
            return items.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .byRating:
            return items.sorted { $0.rating > $1.rating }
        }
    }
}
