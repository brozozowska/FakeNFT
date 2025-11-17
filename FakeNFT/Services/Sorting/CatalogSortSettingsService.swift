import Foundation

protocol SortSettingsService {
    var currentSortOption: SortOption { get set }
}

final class SortSettingsServiceImpl: SortSettingsService {
    private let userDefaults: UserDefaults
    private let sortOptionKey = "catalogSortOption"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var currentSortOption: SortOption {
        get {
            guard let rawValue = userDefaults.string(forKey: sortOptionKey),
                  let option = SortOption(rawValue: rawValue) else {
                return .default
            }
            return option
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: sortOptionKey)
        }
    }
}
