import UIKit
import Kingfisher

protocol CartView: AnyObject, LoadingView, ErrorView { }

final class CartViewController: UIViewController, CartView {

    // MARK: - Constants
    private struct Constants {
        static let bottomBarHeight: CGFloat = 76
        static let contentInset: CGFloat = 16
        static let interItemSpacing: CGFloat = 24
        static let stackSpacing: CGFloat = 4
        static let bottomBarCornerRadius: CGFloat = 16
        static let estimatedRowHeight: CGFloat = 120
        static let payButtonCornerRadius: CGFloat = 16
        
        static let payButtonTitleColor: UIColor = UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return .black
            default:
                return .white
            }
        }
        
        static let payButtonTitleKey = "Cart.pay"
        static let tabTitleKey = "Tab.cart"
        static let tabImageSystemName = "cart"
        static let currencySuffix = "ETH"
        static let errorRepeatKey = "Error.repeat"
    }

    // MARK: - UI
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        return tableView
    }()

    internal lazy var activityIndicator = UIActivityIndicatorView(style: .medium)

    private let bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = Constants.bottomBarCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let itemsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        return label
    }()

    private let totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .systemGreen
        return label
    }()

    private let payButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .label
        button.setTitle(NSLocalizedString(Constants.payButtonTitleKey, comment: "Pay button"), for: .normal)
        button.setTitleColor(Constants.payButtonTitleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = Constants.payButtonCornerRadius
        button.layer.masksToBounds = true
        return button
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Cart.empty", comment: "Empty cart message")
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Formatting
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    // MARK: - Dependencies
    private let viewModel: CartViewModelProtocol

    // MARK: - Init
    init(viewModel: CartViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(
            title: NSLocalizedString(Constants.tabTitleKey, comment: "Cart tab"),
            image: UIImage(systemName: Constants.tabImageSystemName),
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

        setupHierarchy()
        setupConstraints()
        setupActivityIndicator()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NFTCartCell.self, forCellReuseIdentifier: NFTCartCell.defaultReuseIdentifier)

        viewModel.output = self

        viewModel.viewDidLoad()
    }

    // MARK: - Setup
    private func setupHierarchy() {
        view.addSubview(tableView)
        view.addSubview(bottomBar)
        view.addSubview(emptyStateLabel)

        let stackLeft = UIStackView(arrangedSubviews: [itemsCountLabel, totalPriceLabel])
        stackLeft.axis = .vertical
        stackLeft.spacing = Constants.stackSpacing
        stackLeft.translatesAutoresizingMaskIntoConstraints = false

        bottomBar.addSubview(stackLeft)
        bottomBar.addSubview(payButton)

        stackLeft.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        stackLeft.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        guard let stackLeft = bottomBar.subviews.compactMap({ $0 as? UIStackView }).first else { return }

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomBarHeight),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: Constants.bottomBarHeight),

            stackLeft.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: Constants.contentInset),
            stackLeft.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: Constants.contentInset),
            stackLeft.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -Constants.contentInset),

            payButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: Constants.contentInset),
            payButton.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -Constants.contentInset),
            payButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -Constants.contentInset),
            payButton.leadingAnchor.constraint(equalTo: stackLeft.trailingAnchor, constant: Constants.interItemSpacing),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        updateBottomBar()
    }

    // MARK: - Private Methods
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.constraintCenters(to: view)
    }
    
    private func updateEmptyState(isEmpty: Bool) {
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        bottomBar.isHidden = isEmpty
    }

    // MARK: - Helpers
    private func updateBottomBar() {
        let count = viewModel.items.count
        let total = viewModel.items.reduce(Decimal(0)) { $0 + $1.price }
        let totalString = priceFormatter.string(from: total as NSDecimalNumber) ?? "\(total)"

        itemsCountLabel.text = "\(count) NFT"
        totalPriceLabel.text = "\(totalString) \(Constants.currencySuffix)"

        payButton.isEnabled = count > 0
        payButton.alpha = count > 0 ? 1.0 : 0.5
    }
}

// MARK: - CartViewModelOutput
extension CartViewController: CartViewModelOutput {
    func didUpdateItems() {
        let isEmpty = viewModel.items.isEmpty
        updateEmptyState(isEmpty: isEmpty)
        if !isEmpty {
            tableView.reloadData()
            updateBottomBar()
        }
    }

    func didChangeLoading(_ isLoading: Bool) {
        isLoading ? showLoading() : hideLoading()
    }

    func didReceiveError(_ error: Error) {
        let model = ErrorModel(
            message: error.localizedDescription,
            actionText: NSLocalizedString(Constants.errorRepeatKey, comment: "Repeat")
        ) { [weak self] in
            self?.viewModel.refresh()
        }
        showError(model)
    }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NFTCartCell.defaultReuseIdentifier, for: indexPath) as? NFTCartCell else {
            return UITableViewCell()
        }
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item, priceFormatter: priceFormatter, currencySuffix: Constants.currencySuffix)
        cell.onRemoveTapped = { [weak self] id in
            self?.viewModel.removeItem(id: id)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CartViewController: UITableViewDelegate { }
