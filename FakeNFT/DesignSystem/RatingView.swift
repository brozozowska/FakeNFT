import UIKit

final class RatingView: UIView {
    
    // MARK: - Public Properties
    
    var rating: Int {
        get { currentRating }
        set {
            currentRating = newValue
            updateStars()
        }
    }
    
    // MARK: - Private Properties
    
    private var stars: [UIImageView] = []
    private var currentRating: Int = 0
    private let stackView = UIStackView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStars()
    }
    
    // MARK: - Private Methods
    
    private func setupStars() {
        setupStackView()
        createStars()
        setupConstraints()
    }
    
    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
    }
    
    private func createStars() {
        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.image = UIImage(named: "star_inactive")
            stars.append(starImageView)
            stackView.addArrangedSubview(starImageView)
        }
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func updateStars() {
        for (index, star) in stars.enumerated() {
            let imageName = index < currentRating ? "star_active" : "star_inactive"
            star.image = UIImage(named: imageName)
        }
    }
}
