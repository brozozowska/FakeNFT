import UIKit

final class RatingView: UIView {
    
    // MARK: - Private Properties
    
    private var stars: [UIImageView] = []
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Configuration
    
    func setRating(_ rating: Int) {
        for (index, star) in stars.enumerated() {
            let imageName = index < rating ? "star_active" : "star_inactive"
            star.image = UIImage(named: imageName)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupStars() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        
        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.image = UIImage(named: "star_inactive")
            stars.append(starImageView)
            stackView.addArrangedSubview(starImageView)
        }
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
