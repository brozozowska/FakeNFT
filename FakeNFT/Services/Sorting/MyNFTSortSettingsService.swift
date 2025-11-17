import Foundation

protocol MyNFTSortSettingsService: AnyObject {
    var currentSortOption: MyNFTSortOption { get set }
}

final class MyNFTSortSettingsServiceImpl: MyNFTSortSettingsService {
    private let userDefaults: UserDefaults
    private let sortOptionKey = "myNFTSortOption"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var currentSortOption: MyNFTSortOption {
        get {
            guard let rawValue = userDefaults.string(forKey: sortOptionKey),
                  let option = MyNFTSortOption(rawValue: rawValue) else {
                return .default
            }
            return option
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: sortOptionKey)
        }
    }
}
