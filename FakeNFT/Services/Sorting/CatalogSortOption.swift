import Foundation

enum SortOption: String, CaseIterable {
    case byName
    case byNFTCount
    
    var title: String {
        switch self {
        case .byName:
            return NSLocalizedString("Catalog.sort.byName", comment: "")
        case .byNFTCount:
            return NSLocalizedString("Catalog.sort.byNFTCount", comment: "")
        }
    }
    
    static var `default`: SortOption {
        return .byNFTCount
    }
}
