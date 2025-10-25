import Foundation

protocol CartViewModelOutput: AnyObject {
    func didUpdateItems()
    func didChangeLoading(_ isLoading: Bool)
    func didReceiveError(_ error: Error)
}

protocol CartViewModelProtocol: AnyObject {
    var items: [CartItem] { get }
    func viewDidLoad()
    func refresh()
}

final class CartViewModel: CartViewModelProtocol {
    private let cartService: CartServiceProtocol
    private(set) var items: [CartItem] = []
    
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
    
    private func load() {
        output?.didChangeLoading(true)
        cartService.fetchCartItems { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.output?.didChangeLoading(false)
                switch result {
                case .success(let items):
                    self.items = items
                    self.output?.didUpdateItems()
                case .failure(let error):
                    self.output?.didReceiveError(error)
                }
            }
        }
    }
}
