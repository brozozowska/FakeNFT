import UIKit
import Kingfisher

final class CollectionTableViewCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - Constants
    
    private enum Constants {
        static let coverImageHeight: CGFloat = 140
        static let coverImageCornerRadius: CGFloat = 12
        static let horizontalInset: CGFloat = 16
        static let titleTopInset: CGFloat = 4
        static let titleHeight: CGFloat = 22
        static let contentBottomInset: CGFloat = 13
        static let imageFadeDuration: TimeInterval = 0.3
    }
    
    // MARK: - UI Components
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.coverImageCornerRadius
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .black
        label.numberOfLines = .zero
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Configuration
    
    func configure(with collection: NFTCollection) {
        let nftCount = collection.displayNFTCount
        let nftText = NSLocalizedString("Catalog.nftCount", value: "NFT", comment: "")
        let titleText = "\(collection.name) (\(nftCount) \(nftText))"
        
        let attributedString = NSMutableAttributedString(string: titleText)
        
        if let nftRange = titleText.range(of: "(\(nftCount) \(nftText))") {
            let nsRange = NSRange(nftRange, in: titleText)
            attributedString.addAttribute(.font, value: UIFont.bodyBold, range: nsRange)
        }
        
        titleLabel.attributedText = attributedString
        
        loadCoverImage(for: collection)
    }
    
    private func loadCoverImage(for collection: NFTCollection) {
        coverImageView.image = nil
        coverImageView.backgroundColor = .lightGray
        
        guard let coverURL = collection.coverURL else {
            coverImageView.backgroundColor = .lightGray
            print("Invalid cover URL for collection: \(collection.name)")
            return
        }
        
        coverImageView.backgroundColor = .lightGray
        
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
                    print("Successfully loaded image from: \(coverURL)")
                case .failure(let error):
                    self?.coverImageView.backgroundColor = .lightGray
                    print("Failed to load image from: \(coverURL), error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        contentView.backgroundColor = .white
        selectionStyle = .none
        
        [coverImageView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            coverImageView.heightAnchor.constraint(equalToConstant: Constants.coverImageHeight),
            
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: Constants.titleTopInset),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.titleHeight),
            
            contentView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.contentBottomInset)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.kf.cancelDownloadTask()
        coverImageView.image = nil
        coverImageView.backgroundColor = .lightGray
    }
}
