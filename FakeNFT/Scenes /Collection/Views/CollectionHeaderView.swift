import UIKit
import Kingfisher

final class CollectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "CollectionHeaderView"
    
    // MARK: - Callbacks
    
    var onAuthorTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = .black
        label.numberOfLines = .zero
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .black
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
        
        let baseText = "Автор коллекции: "
        let authorText = "\(baseText)\(author)"
        let attributedString = NSMutableAttributedString(string: authorText)
        
        let baseRange = NSRange(location: 0, length: baseText.count)
        attributedString.addAttribute(.font, value: UIFont.caption2, range: baseRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: baseRange)
        
        let authorRange = NSRange(location: baseText.count, length: author.count)
        attributedString.addAttribute(.font, value: UIFont.caption1, range: authorRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.blueUniversal, range: authorRange)
        
        authorLabel.attributedText = attributedString
        
        descriptionLabel.text = collection.description
        
        loadCoverImage(for: collection)
    }
    
    private func loadCoverImage(for collection: NFTCollection) {
        coverImageView.image = nil
        coverImageView.backgroundColor = .lightGray
        
        if let coverURL = collection.coverURL {
            coverImageView.kf.setImage(
                with: coverURL,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.coverImageView.backgroundColor = .clear
                    case .failure(_):
                        self?.coverImageView.backgroundColor = .lightGray
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        backgroundColor = .white
        
        addSubview(coverImageView)
        addSubview(titleLabel)
        addSubview(authorLabel)
        addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 310),
            
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
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
        coverImageView.backgroundColor = .lightGray
    }
}
