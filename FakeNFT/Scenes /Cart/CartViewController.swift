import UIKit
import Kingfisher

// MARK: - Protocol
protocol CartView: AnyObject, LoadingView, ErrorView { }

// MARK: - CartViewController
final class CartViewController: UIViewController, CartView {

    // MARK: - Constants
    private enum Constants {
        enum Layout {
            static let bottomBarHeight: CGFloat = 76
            static let contentInset: CGFloat = 16
            static let interItemSpacing: CGFloat = 24
            static let stackSpacing: CGFloat = 4
            static let bottomBarCornerRadius: CGFloat = 16
            static let estimatedRowHeight: CGFloat = 120
        }

        enum PayButton {
            static let cornerRadius: CGFloat = 16
            static let titleFontSize: CGFloat = 17
        }

        enum Fonts {
            static let itemsCountFontSize: CGFloat = 15
            static let totalPriceFontSize: CGFloat = 17
        }

        enum Colors {
            static let payButtonTitleColor: UIColor = UIColor { traits in
                switch traits.userInterfaceStyle {
                case .dark:
                    return .black
                default:
                    return .white
                }
            }
        }

        enum Strings {
            static let emptyCartKey = "Cart.empty"
            static let payButtonTitleKey = "Cart.pay"
            static let tabTitleKey = "Tab.cart"
            static let errorRepeatKey = "Error.repeat"
        }

        enum Images {
            static let tabImageSystemName = "cart"
        }

        enum Defaults {
            static let currency = "ETH"
        }
    }

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.Layout.estimatedRowHeight
        return tableView
    }()

    private lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = Constants.Layout.bottomBarCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private lazy var itemsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Fonts.itemsCountFontSize, weight: .regular)
        label.textColor = .label
        return label
    }()

    private lazy var totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Fonts.totalPriceFontSize, weight: .bold)
        label.textColor = .systemGreen
        return label
    }()

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .label
        button.setTitle(NSLocalizedString(Constants.Strings.payButtonTitleKey, comment: "Pay button"), for: .normal)
        button.setTitleColor(Constants.Colors.payButtonTitleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.PayButton.titleFontSize, weight: .bold)
        button.layer.cornerRadius = Constants.PayButton.cornerRadius
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString(Constants.Strings.emptyCartKey, comment: "Empty cart message")
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    lazy var activityIndicator = UIActivityIndicatorView(style: .medium)

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
    private let currencyService: CurrencyServiceProtocol
    
    // MARK: - State
    private var selectedCurrency: String = Constants.Defaults.currency {
        didSet { updateBottomBar() }
    }

    // MARK: - Init
    init(viewModel: CartViewModelProtocol, currencyService: CurrencyServiceProtocol) {
        self.viewModel = viewModel
        self.currencyService = currencyService
        super.init(nibName: nil, bundle: nil)
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
        setupNavigationBar()

        tableView.dataSource = self
        tableView.register(NFTCartCell.self, forCellReuseIdentifier: NFTCartCell.defaultReuseIdentifier)

        viewModel.output = self

        NotificationCenter.default.addObserver(self, selector: #selector(onCurrencySelected(_:)), name: .didSelectCurrency, object: nil)
        
        viewModel.viewDidLoad()
    }

    // MARK: - Setup
    private func setupHierarchy() {
        [
            tableView,
            bottomBar,
            emptyStateLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        let stackLeft = UIStackView(arrangedSubviews: [itemsCountLabel, totalPriceLabel])
        stackLeft.axis = .vertical
        stackLeft.spacing = Constants.Layout.stackSpacing
        stackLeft.translatesAutoresizingMaskIntoConstraints = false

        [
            stackLeft,
            payButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomBar.addSubview($0)
        }

        stackLeft.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        stackLeft.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        guard let stackLeft = bottomBar.subviews.compactMap({ $0 as? UIStackView }).first else { return }

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.bottomBarHeight),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: Constants.Layout.bottomBarHeight),

            stackLeft.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: Constants.Layout.contentInset),
            stackLeft.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: Constants.Layout.contentInset),
            stackLeft.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -Constants.Layout.contentInset),

            payButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: Constants.Layout.contentInset),
            payButton.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -Constants.Layout.contentInset),
            payButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -Constants.Layout.contentInset),
            payButton.leadingAnchor.constraint(equalTo: stackLeft.trailingAnchor, constant: Constants.Layout.interItemSpacing),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        updateBottomBar()
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.constraintCenters(to: view)
    }
    
    private func setupNavigationBar() {
        let sortButton = UIBarButtonItem(
            image: UIImage(resource: .sort),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortButton.tintColor = .label
        navigationItem.rightBarButtonItem = sortButton
    }

    // MARK: - Actions
    @objc private func payButtonTapped() {
        openCurrencySelection()
    }
    
    @objc private func onCurrencySelected(_ notification: Notification) {
        guard let currency = notification.object as? Currency else { return }
        selectedCurrency = currency.name
    }
    
    @objc private func sortButtonTapped() { }
    
    // MARK: - State
    private func updateEmptyState(isEmpty: Bool) {
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        bottomBar.isHidden = isEmpty
    }
    
    // MARK: - Navigation
    private func openCurrencySelection() {
        let currencyViewModel = CurrencyViewModel(currencyService: currencyService)
        let viewController = CurrencyViewController(viewModel: currencyViewModel)
        viewController.hidesBottomBarWhenPushed = true
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .label
        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Helpers
    private func updateBottomBar() {
        let count = viewModel.items.count
        let total = viewModel.items.reduce(Decimal(0)) { $0 + $1.price }
        let totalString = priceFormatter.string(from: total as NSDecimalNumber) ?? "\(total)"

        itemsCountLabel.text = "\(count) NFT"
        totalPriceLabel.text = "\(totalString) \(selectedCurrency)"
    }

    // MARK: - Delete confirmation
    private func showDeleteConfirmation(for item: CartItem) {
        let overlay = DeleteConfirmationView()
        overlay.configure(imageURL: item.imageURL)
        overlay.onCancel = { [weak overlay] in
            overlay?.dismiss()
        }
        overlay.onConfirm = { [weak self, weak overlay] in
            overlay?.dismiss()
            self?.viewModel.removeItem(id: item.id)
        }
        if let host = tabBarController?.view ?? navigationController?.view ?? view {
            overlay.present(in: host)
        } else {
            overlay.present(in: view)
        }
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
            actionText: NSLocalizedString(Constants.Strings.errorRepeatKey, comment: "Repeat")
        ) { [weak self] in
            self?.viewModel.refresh()
        }
        showError(model)
    }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NFTCartCell.defaultReuseIdentifier, for: indexPath) as? NFTCartCell else {
            return UITableViewCell()
        }
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item, priceFormatter: priceFormatter, currencySuffix: Constants.Defaults.currency)
        cell.onRemoveTapped = { [weak self] _ in
            guard let self else { return }
            let item = self.viewModel.items[indexPath.row]
            self.showDeleteConfirmation(for: item)
        }
        return cell
    }
}
