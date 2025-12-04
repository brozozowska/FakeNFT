import Foundation

protocol SortSettingsService {
    var currentSortOption: CatalogSortOption { get set }
}

final class SortSettingsServiceImpl: SortSettingsService {
    private let userDefaults: UserDefaults
    private let sortOptionKey = "catalogSortOption"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var currentSortOption: CatalogSortOption {
        get {
            guard let rawValue = userDefaults.string(forKey: sortOptionKey),
                  let option = CatalogSortOption(rawValue: rawValue) else {
                return .default
            }
            return option
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: sortOptionKey)
        }
    }
}
