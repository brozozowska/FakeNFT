import Foundation

enum MyNFTSortOption: String, CaseIterable {
    case byPrice
    case byRating
    case byName
    
    var title: String {
        switch self {
        case .byPrice:
            return NSLocalizedString("MyNFTs.sort.byPrice", comment: "By price")
        case .byRating:
            return NSLocalizedString("MyNFTs.sort.byRating", comment: "By rating")
        case .byName:
            return NSLocalizedString("MyNFTs.sort.byName", comment: "By name")
        }
    }
    
    static var `default`: MyNFTSortOption {
        return .byRating
    }
}
