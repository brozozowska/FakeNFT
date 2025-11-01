//
//  StatisticsViewModel.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import Foundation

final class StatisticsViewModel {

    // Outputs (биндинги)
    var onLoading: ((Bool) -> Void)?
    var onUsers: (([User]) -> Void)?
    var onError: ((ErrorModel) -> Void)?

    private let service: UsersService
    private var prefs: SortPreferences              // <-- было let, стало var
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
        onLoading?(true)
        service.loadUsers { [weak self] result in
            guard let self else { return }
            self.onLoading?(false)
            switch result {
            case .success(let list):
                self.users = self.sortedUsers(list, by: self.currentSort)   // <-- новое имя
                self.onUsers?(self.users)
            case .failure:
                self.onError?(
                    ErrorModel(
                        message: "Не удалось загрузить рейтинг",
                        actionText: "Повторить",
                        action: { [weak self] in self?.load() }
                    )
                )
            }
        }
    }

    func changeSort(to sort: StatisticsSort) {
        currentSort = sort
        users = sortedUsers(users, by: sort)        // <-- новое имя
        onUsers?(users)
    }

    // MARK: - Private
    private func sortedUsers(_ items: [User], by sort: StatisticsSort) -> [User] { // <-- переименовано
        switch sort {
        case .byName:
            return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .byRating:
            return items.sorted { $0.rating > $1.rating }
        }
    }
}
