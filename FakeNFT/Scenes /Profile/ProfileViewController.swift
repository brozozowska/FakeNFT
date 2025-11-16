import UIKit
import Kingfisher
import Combine

final class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let profileContainerHeight: CGFloat = 162
        static let profileContainerTopInset: CGFloat = 20
        static let avatarSize: CGFloat = 70
        static let avatarTopInset: CGFloat = 20
        static let avatarLeadingInset: CGFloat = 16
        static let nameLeadingInset: CGFloat = 16
        static let nameTrailingInset: CGFloat = 16
        static let descriptionTopInset: CGFloat = 20
        static let descriptionHorizontalInset: CGFloat = 16
        static let websiteButtonTopInset: CGFloat = 200
        static let websiteButtonLeadingInset: CGFloat = 16
        static let websiteButtonWidth: CGFloat = 147
        static let websiteButtonHeight: CGFloat = 28
        static let tableViewTopInset: CGFloat = 278
        static let tableViewRowHeight: CGFloat = 54
        static let tableViewSectionSpacing: CGFloat = 8
        static let avatarCornerRadius: CGFloat = 35
    }
    
    // MARK: - Properties
    
    private let viewModel: ProfileViewModel
    private let viewModelFactory: ViewModelFactory
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var profileContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.avatarCornerRadius
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = .black
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .black
        label.numberOfLines = .zero
        return label
    }()
    
    private lazy var websiteButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.blueUniversal, for: .normal)
        button.titleLabel?.font = .caption1
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(websiteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(resource: .edit),
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
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
    
    init(viewModel: ProfileViewModel, viewModelFactory: ViewModelFactory) {
        self.viewModel = viewModel
        self.viewModelFactory = viewModelFactory
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) is not supported for ProfileViewController. Use init(viewModel:viewModelFactory:) instead.")
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadProfile()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        setupNavigationItems()
        configureNavigationBarAppearance()
    }
    
    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = editButton
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func configureNavigationBarAppearance() {
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        profileContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileContainerView)
        
        [avatarImageView, nameLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            profileContainerView.addSubview($0)
        }
        
        [websiteButton, tableView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.profileContainerTopInset),
            profileContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileContainerView.heightAnchor.constraint(equalToConstant: Constants.profileContainerHeight),
            
            avatarImageView.topAnchor.constraint(equalTo: profileContainerView.topAnchor, constant: Constants.avatarTopInset),
            avatarImageView.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: Constants.avatarLeadingInset),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Constants.nameLeadingInset),
            nameLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -Constants.nameTrailingInset),
            
            descriptionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constants.descriptionTopInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: Constants.descriptionHorizontalInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -Constants.descriptionHorizontalInset),
            
            websiteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.websiteButtonTopInset),
            websiteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.websiteButtonLeadingInset),
            websiteButton.widthAnchor.constraint(equalToConstant: Constants.websiteButtonWidth),
            websiteButton.heightAnchor.constraint(equalToConstant: Constants.websiteButtonHeight),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.tableViewTopInset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: Constants.tableViewRowHeight * 2 + Constants.tableViewSectionSpacing),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$profile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.updateUI(with: profile)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with profile: Profile?) {
        guard let profile else { return }
        
        nameLabel.text = profile.name
        descriptionLabel.text = profile.description
        websiteButton.setTitle(profile.website, for: .normal)
        
        loadAvatar(from: profile.avatar)
        
        tableView.reloadData()
    }
    
    private func loadAvatar(from urlString: String) {
        let fullURLString: String
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            fullURLString = urlString
        } else {
            fullURLString = "\(RequestConstants.baseURL)\(urlString)"
        }
        
        guard let url = URL(string: fullURLString) else {
            avatarImageView.image = UIImage(named: "Avatar")
            return
        }
        
        let modifier = AnyModifier { request in
            var r = request
            r.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
            return r
        }
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Avatar"),
            options: [.requestModifier(modifier)]
        )
    }
    
    @objc private func websiteButtonTapped() {
        guard let website = viewModel.profile?.website,
              let url = URL(string: website) else { return }
        
        let webViewController = WebViewViewController(url: url)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    @objc private func editButtonTapped() {
        guard let profile = viewModel.profile else { return }
        
        let editViewModel = viewModelFactory.makeEditProfileViewModel(profile: profile)
        let editViewController = EditProfileViewController(viewModel: editViewModel)
        navigationController?.pushViewController(editViewController, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.textLabel?.font = .bodyBold
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("Profile.myNFTs", comment: "My NFTs")
        case 1:
            cell.textLabel?.text = NSLocalizedString("Profile.favorites", comment: "Favorites")
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let myNFTsViewModel = viewModelFactory.makeMyNFTsViewModel()
            let myNFTsViewController = MyNFTsViewController(viewModel: myNFTsViewModel)
            navigationController?.pushViewController(myNFTsViewController, animated: true)
        case 1:
            let favoritesViewModel = viewModelFactory.makeFavoritesViewModel()
            let favoritesViewController = FavoritesViewController(viewModel: favoritesViewModel)
            navigationController?.pushViewController(favoritesViewController, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.tableViewRowHeight
    }
}
