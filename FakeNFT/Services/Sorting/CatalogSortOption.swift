import Foundation

enum CatalogSortOption: String, CaseIterable {
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
    
    static var `default`: CatalogSortOption {
        return .byNFTCount
    }
}
