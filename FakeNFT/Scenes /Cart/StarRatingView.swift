import UIKit

final class StarRatingView: UIView {
    private let stack = UIStackView()
    private var starImageViews: [UIImageView] = []
    private let starsCount: Int
    private let starSize: CGFloat
    private let spacing: CGFloat

    var rating: Int = 0 {
        didSet { updateStars() }
    }

    init(stars: Int, starSize: CGFloat = 12, spacing: CGFloat = 4) {
        self.starsCount = stars
        self.starSize = starSize
        self.spacing = spacing
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        self.starsCount = 5
        self.starSize = 12
        self.spacing = 4
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        for _ in 0..<starsCount {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemYellow
            imageView.widthAnchor.constraint(equalToConstant: starSize).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: starSize).isActive = true
            starImageViews.append(imageView)
            stack.addArrangedSubview(imageView)
        }
        updateStars()
    }

    private func updateStars() {
        for (index, imageView) in starImageViews.enumerated() {
            if index < rating {
                imageView.image = UIImage(systemName: "star.fill")
                imageView.tintColor = .systemYellow
            } else {
                imageView.image = UIImage(systemName: "star")
                imageView.tintColor = .tertiaryLabel
            }
        }
    }
}
