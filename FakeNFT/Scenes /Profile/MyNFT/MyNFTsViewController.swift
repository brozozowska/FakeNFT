import UIKit
import Combine

final class MyNFTsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MyNFTsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MyNFTCell.self, forCellReuseIdentifier: "MyNFTCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("MyNFTs.empty", comment: "No NFTs yet")
        label.font = .bodyBold
        label.textColor = .black
        label.textAlignment = .center
        label.isHidden = true
        return label
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
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(viewModel: MyNFTsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()
        setupNavigationBar()
        
        print("MyNFTsViewController loaded")
        viewModel.loadMyNFTs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("MyNFTsViewController will appear")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .white
        title = NSLocalizedString("MyNFTs.title", comment: "My NFTs")
        navigationItem.rightBarButtonItem = sortButton
        
        [tableView, emptyStateLabel, activityIndicator].forEach {
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
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = sortButton
    }
    
    private func setupBindings() {
        viewModel.$nfts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nfts in
                print("NFTs updated in ViewModel: \(nfts.count) items")
                self?.tableView.reloadData()
                self?.emptyStateLabel.isHidden = !nfts.isEmpty
                print("Table view reloaded, empty state hidden: \(nfts.isEmpty)")
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                print("Loading state: \(isLoading)")
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
    }
    
    @objc private func sortButtonTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("MyNFTs.sort.title", comment: "Sorting"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        for option in MyNFTSortOption.allCases {
            let action = UIAlertAction(title: option.title, style: .default) { [weak self] _ in
                self?.viewModel.updateSortOption(option)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("MyNFTs.sort.cancel", comment: "Cancel"),
            style: .cancel
        ))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MyNFTsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.nfts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyNFTCell", for: indexPath) as? MyNFTCell else {
            return UITableViewCell()
        }
        
        let nft = viewModel.nfts[indexPath.row]
        print("Configuring cell for NFT: \(nft.name) at index \(indexPath.row)")
        cell.configure(with: nft)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
