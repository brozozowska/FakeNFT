import UIKit

final class StarRatingView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        enum Layout {
            static let defaultStarSize: CGFloat = 12
            static let defaultSpacing: CGFloat = 4
        }
        
        enum Colors {
            static let filled: UIColor = .systemYellow
            static let empty: UIColor = .tertiaryLabel
        }
        
        enum Images {
            static let filledSystemName = "star.fill"
            static let emptySystemName = "star"
        }
        
        enum Defaults {
            static let starsCount: Int = 5
        }
    }
    
    // MARK: - UI
    private let stack = UIStackView()
    private var starImageViews: [UIImageView] = []
    
    // MARK: - Properties
    private let starsCount: Int
    private let starSize: CGFloat
    private let spacing: CGFloat
    
    // MARK: - Public Properties
    var rating: Int = 0 {
        didSet { updateStars() }
    }
    
    // MARK: - Init
    init(
        stars: Int,
        starSize: CGFloat = Constants.Layout.defaultStarSize,
        spacing: CGFloat = Constants.Layout.defaultSpacing
    ) {
        self.starsCount = stars
        self.starSize = starSize
        self.spacing = spacing
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Setup
    private func setup() {
        setupHierarchy()
        setupConstraints()
        setupAppearance()
        updateStars()
    }
    
    private func setupHierarchy() {
        addSubview(stack)
        for _ in 0..<starsCount {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            starImageViews.append(imageView)
            stack.addArrangedSubview(imageView)
        }
    }
    
    private func setupConstraints() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        starImageViews.forEach { imageView in
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: starSize).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: starSize).isActive = true
        }
    }
    
    private func setupAppearance() {
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.alignment = .center
    }
    
    // MARK: - Private Methods
    private func updateStars() {
        for (index, imageView) in starImageViews.enumerated() {
            if index < rating {
                imageView.image = UIImage(systemName: Constants.Images.filledSystemName)
                imageView.tintColor = Constants.Colors.filled
            } else {
                imageView.image = UIImage(systemName: Constants.Images.emptySystemName)
                imageView.tintColor = Constants.Colors.empty
            }
        }
    }
}
