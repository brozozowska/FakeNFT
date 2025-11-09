import UIKit
import Combine

final class CatalogViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: CatalogViewModel
    private let servicesAssembly: ServicesAssembly
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CollectionTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(named: "sort-lines"),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        button.tintColor = .black
        return button
    }()
    
    internal lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(viewModel: CatalogViewModel, servicesAssembly: ServicesAssembly) {
        self.viewModel = viewModel
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) is not supported for CatalogViewController. Use init(viewModel:) instead.")
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupNavigationBar()
        setupBindings()
        viewModel.loadCollections()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .white
        
        [tableView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = sortButton
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.navigationBar.tintColor = .black
    }
    
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.showLoading() : self?.hideLoading()
            }
            .store(in: &cancellables)
        
        viewModel.$collections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$errorModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorModel in
                if let errorModel = errorModel {
                    self?.showError(errorModel)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func sortButtonTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("Catalog.sort.title", comment: ""),
            message: NSLocalizedString("Catalog.sort.message", comment: ""),
            preferredStyle: .actionSheet
        )
        
        for option in SortOption.allCases {
            let action = UIAlertAction(title: option.title, style: .default) { [weak self] _ in
                self?.viewModel.updateSortOption(option)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Catalog.sort.cancel", comment: ""),
            style: .cancel
        ))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.collectionsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CollectionTableViewCell = tableView.dequeueReusableCell()
        let collection = viewModel.collection(at: indexPath.row)
        cell.configure(with: collection)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let collection = viewModel.collection(at: indexPath.row)
        guard let viewModelAssembly = (tabBarController as? TabBarController)?.viewModelAssembly else { return }
        let collectionViewModel = viewModelAssembly.makeCollectionViewModel(collection: collection)
        let collectionViewController = CollectionViewController(viewModel: collectionViewModel)
        navigationController?.pushViewController(collectionViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        179
    }
}

// MARK: - LoadingView & ErrorView

extension CatalogViewController: LoadingView, ErrorView {
    func showLoading() {
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
}
