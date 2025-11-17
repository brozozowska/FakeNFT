import UIKit
import Kingfisher

final class CollectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "CollectionHeaderView"
    
    // MARK: - Constants
    
    private enum Constants {
        static let coverImageHeight: CGFloat = 310
        static let horizontalSpacing: CGFloat = 16
        static let verticalSpacingSmall: CGFloat = 8
        static let verticalSpacingMedium: CGFloat = 16
        static let imageFadeDuration: TimeInterval = 0.3
        
        enum Colors {
            static let backgroundColor = UIColor.white
            static let textColor = UIColor.black
            static let authorHighlightColor = UIColor.blueUniversal
            static let placeholderColor = UIColor.lightGray
        }
        
        enum Fonts {
            static let title = UIFont.headline3
            static let author = UIFont.caption1
            static let description = UIFont.caption2
            static let authorPrefix = UIFont.caption2
        }
        
        enum Text {
            static let authorPrefix = "Автор коллекции: "
        }
    }
    
    // MARK: - Callbacks
    
    var onAuthorTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = Constants.Colors.placeholderColor
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.title
        label.textColor = Constants.Colors.textColor
        label.numberOfLines = .zero
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.author
        label.textColor = Constants.Colors.textColor
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.description
        label.textColor = Constants.Colors.textColor
        label.numberOfLines = .zero
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupGestures()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Configuration
    
    func configure(with collection: NFTCollection, author: String) {
        titleLabel.text = collection.name
        setupAuthorText(author: author)
        descriptionLabel.text = collection.description
        loadCoverImage(for: collection)
    }
    
    private func setupAuthorText(author: String) {
        let authorText = "\(Constants.Text.authorPrefix)\(author)"
        let attributedString = NSMutableAttributedString(string: authorText)
        
        let baseRange = NSRange(location: .zero, length: Constants.Text.authorPrefix.count)
        attributedString.addAttribute(.font, value: Constants.Fonts.authorPrefix, range: baseRange)
        attributedString.addAttribute(.foregroundColor, value: Constants.Colors.textColor, range: baseRange)
        
        let authorRange = NSRange(location: Constants.Text.authorPrefix.count, length: author.count)
        attributedString.addAttribute(.font, value: Constants.Fonts.author, range: authorRange)
        attributedString.addAttribute(.foregroundColor, value: Constants.Colors.authorHighlightColor, range: authorRange)
        
        authorLabel.attributedText = attributedString
    }
    
    private func loadCoverImage(for collection: NFTCollection) {
        coverImageView.image = nil
        coverImageView.backgroundColor = Constants.Colors.placeholderColor
        
        if let coverURL = collection.coverURL {
            coverImageView.kf.setImage(
                with: coverURL,
                options: [
                    .transition(.fade(Constants.imageFadeDuration)),
                    .cacheOriginalImage
                ]
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.coverImageView.backgroundColor = .clear
                    case .failure(_):
                        self?.coverImageView.backgroundColor = Constants.Colors.placeholderColor
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        backgroundColor = Constants.Colors.backgroundColor
        
        [
            coverImageView,
            titleLabel,
            authorLabel,
            descriptionLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: Constants.coverImageHeight),
            
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: Constants.verticalSpacingMedium),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalSpacing),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.verticalSpacingSmall),
            authorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalSpacing),
            authorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalSpacing),
            
            descriptionLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: Constants.verticalSpacingSmall),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalSpacing),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalSpacing),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalSpacingMedium)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(authorLabelTapped))
        authorLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func authorLabelTapped() {
        onAuthorTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.kf.cancelDownloadTask()
        coverImageView.image = nil
        coverImageView.backgroundColor = Constants.Colors.placeholderColor
    }
}
