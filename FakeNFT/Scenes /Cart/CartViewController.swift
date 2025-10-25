import UIKit
import Kingfisher

protocol CartView: AnyObject, LoadingView, ErrorView { }

final class CartViewController: UIViewController, CartView {
    
    // MARK: - Dependencies
    private let viewModel: CartViewModelProtocol
    
    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    internal lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Init
    init(viewModel: CartViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Tab.cart", comment: "Cart tab title")
        tabBarItem = UITabBarItem(
            title: NSLocalizedString("Tab.cart", comment: ""),
            image: UIImage(systemName: "cart"),
            tag: 1
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTable()
        setupActivityIndicator()
        
        if let vm = viewModel as? CartViewModel {
            vm.output = self
        }
        
        viewModel.viewDidLoad()
    }
    
    // MARK: - Setup
    private func setupTable() {
        view.addSubview(tableView)
        tableView.constraintEdges(to: view)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.constraintCenters(to: view)
    }
}

// MARK: - CartViewModelOutput
extension CartViewController: CartViewModelOutput {
    func didUpdateItems() {
        tableView.reloadData()
    }
    
    func didChangeLoading(_ isLoading: Bool) {
        isLoading ? showLoading() : hideLoading()
    }
    
    func didReceiveError(_ error: Error) {
        let model = ErrorModel(
            message: error.localizedDescription,
            actionText: NSLocalizedString("Error.repeat", comment: "Repeat")
        ) { [weak self] in
            self?.viewModel.refresh()
        }
        showError(model)
    }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (viewModel as? CartViewModel)?.items.count ?? viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = viewModel.items[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        config.secondaryText = "★ \(item.rating)  •  \(item.price)"
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CartViewController: UITableViewDelegate { }
