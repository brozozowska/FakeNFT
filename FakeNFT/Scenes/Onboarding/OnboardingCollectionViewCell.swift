import UIKit

// MARK: - Constants
private enum OnboardingConstants {
    static let darkOverlayAlpha: CGFloat = 0.2
    static let titleTopOffset: CGFloat = 230
    static let horizontalPadding: CGFloat = 16
    static let descriptionTopOffset: CGFloat = 12
    static let buttonBottomOffset: CGFloat = 50
    static let buttonHeight: CGFloat = 60
    static let buttonCornerRadius: CGFloat = 16
    
    // Shadow properties
    static let shadowColor: UIColor = .black
    static let shadowRadius: CGFloat = 2.0
    static let shadowOpacity: Float = 0.6
    static let shadowOffset = CGSize(width: 1, height: 1)
    
    // Page control
    static let pageControlTopOffset: CGFloat = 44
    static let pageControlHeight: CGFloat = 28
}

final class OnboardingCollectionViewCell: UICollectionViewCell, ReuseIdentifying {
    
    // MARK: - Properties
    var onLoginButtonTapped: (() -> Void)?
    
    // MARK: - UI Components
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var darkOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(OnboardingConstants.darkOverlayAlpha)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        
        label.layer.shadowColor = OnboardingConstants.shadowColor.cgColor
        label.layer.shadowRadius = OnboardingConstants.shadowRadius
        label.layer.shadowOpacity = OnboardingConstants.shadowOpacity
        label.layer.shadowOffset = OnboardingConstants.shadowOffset
        label.layer.masksToBounds = false
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyRegular
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = .zero
        
        label.layer.shadowColor = OnboardingConstants.shadowColor.cgColor
        label.layer.shadowRadius = OnboardingConstants.shadowRadius
        label.layer.shadowOpacity = OnboardingConstants.shadowOpacity
        label.layer.shadowOffset = OnboardingConstants.shadowOffset
        label.layer.masksToBounds = false
        
        return label
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .bodyBold
        button.layer.cornerRadius = OnboardingConstants.buttonCornerRadius
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with slide: OnboardingSlide) {
        imageView.image = UIImage(named: slide.imageName)
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
        loginButton.isHidden = !slide.isLastSlide
        
        if slide.isLastSlide {
            loginButton.setTitle(NSLocalizedString("Onboarding.login.button", value: "Что внутри?", comment: ""), for: .normal)
        }
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped() {
        onLoginButtonTapped?()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        contentView.backgroundColor = .white
        
        [imageView, darkOverlay, titleLabel, descriptionLabel, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Dark overlay - поверх картинки
            darkOverlay.topAnchor.constraint(equalTo: imageView.topAnchor),
            darkOverlay.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            darkOverlay.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            darkOverlay.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            // Title and description
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: OnboardingConstants.titleTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: OnboardingConstants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -OnboardingConstants.horizontalPadding),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: OnboardingConstants.descriptionTopOffset),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: OnboardingConstants.horizontalPadding),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -OnboardingConstants.horizontalPadding),
            
            // Login button
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: OnboardingConstants.horizontalPadding),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -OnboardingConstants.horizontalPadding),
            loginButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -OnboardingConstants.buttonBottomOffset),
            loginButton.heightAnchor.constraint(equalToConstant: OnboardingConstants.buttonHeight)
        ])
    }
}
