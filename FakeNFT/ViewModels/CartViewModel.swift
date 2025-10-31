import Foundation

protocol CartViewModelOutput: AnyObject {
    func didUpdateItems()
    func didChangeLoading(_ isLoading: Bool)
    func didReceiveError(_ error: Error)
}

protocol CartViewModelProtocol: AnyObject {
    var items: [CartItem] { get }
    var output: CartViewModelOutput? { get set }
    func viewDidLoad()
    func refresh()
    func removeItem(id: String)
    func applySort(_ option: SortOption)
}

final class CartViewModel: CartViewModelProtocol {
    private let cartService: CartServiceProtocol
    private(set) var items: [CartItem] = []
    private var currentSort: SortOption?

    weak var output: CartViewModelOutput?
    
    init(cartService: CartServiceProtocol) {
        self.cartService = cartService
    }
    
    func viewDidLoad() {
        load()
    }
    
    func refresh() {
        load()
    }
    
    func removeItem(id: String) {
        output?.didChangeLoading(true)
        cartService.removeItem(with: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.output?.didChangeLoading(false)
                switch result {
                case .success:
                    self.items.removeAll { $0.id == id }
                    self.output?.didUpdateItems()
                case .failure(let error):
                    self.output?.didReceiveError(error)
                }
            }
        }
    }

    func applySort(_ option: SortOption) {
        currentSort = option
        sortItems()
        output?.didUpdateItems()
    }
    
    private func load() {
        output?.didChangeLoading(true)
        cartService.fetchCartItems { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.output?.didChangeLoading(false)
                switch result {
                case .success(let items):
                    self.items = items
                    self.sortItems()
                    self.output?.didUpdateItems()
                case .failure(let error):
                    self.output?.didReceiveError(error)
                }
            }
        }
    }

    private func sortItems() {
        guard let currentSort else { return }
        switch currentSort {
        case .price:
            items.sort { $0.price < $1.price }
        case .rating:
            items.sort { $0.rating < $1.rating }
        case .name:
            items.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }
}
