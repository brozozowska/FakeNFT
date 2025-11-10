import UIKit
import Kingfisher
import Combine

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ProfileViewModel
    private let servicesAssembly: ServicesAssembly
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
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.image = UIImage(named: "Avatar")
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
            image: UIImage(named: "Edit"),
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
    
    init(viewModel: ProfileViewModel, servicesAssembly: ServicesAssembly) {
        self.viewModel = viewModel
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) is not supported for ProfileViewController. Use init(viewModel:) instead.")
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
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = editButton
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
            profileContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileContainerView.heightAnchor.constraint(equalToConstant: 162),
            
            avatarImageView.topAnchor.constraint(equalTo: profileContainerView.topAnchor, constant: 20),
            avatarImageView.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -16),
            
            websiteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 278),
            websiteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            websiteButton.widthAnchor.constraint(equalToConstant: 147),
            websiteButton.heightAnchor.constraint(equalToConstant: 28),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 346),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 54 * 2 + 8),
            
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
            
            avatarImageView.image = UIImage(named: "Avatar")
            
            tableView.reloadData()
        }
    
    @objc private func websiteButtonTapped() {
        guard let website = viewModel.profile?.website,
              let url = URL(string: website) else { return }
        
        let webViewController = WebViewViewController(url: url)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    @objc private func editButtonTapped() {
        guard let profile = viewModel.profile else { return }
        
        let editViewController = EditProfileViewController(
            profile: profile,
            onSave: { [weak self] name, description, website, avatar in
                self?.viewModel.updateProfile(
                    name: name,
                    description: description,
                    website: website,
                    avatar: avatar
                )
            }
        )
        
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
            let myNFTsViewModel = ViewModelAssembly(servicesAssembly: servicesAssembly).makeMyNFTsViewModel()
            let myNFTsViewController = MyNFTsViewController(viewModel: myNFTsViewModel)
            navigationController?.pushViewController(myNFTsViewController, animated: true)
        case 1:
            let favoritesViewModel = ViewModelAssembly(servicesAssembly: servicesAssembly).makeFavoritesViewModel()
            let favoritesViewController = FavoritesViewController(viewModel: favoritesViewModel)
            navigationController?.pushViewController(favoritesViewController, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        54
    }
}
