import UIKit
import Kingfisher

final class MyNFTCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - UI Components
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline4
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .black
        label.text = NSLocalizedString("MyNFTs.price", comment: "Price")
        return label
    }()
    
    private lazy var priceValueLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var ratingView: RatingView = {
        let view = RatingView()
        return view
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Configuration
    
    func configure(with nft: Nft) {
        nameLabel.text = nft.name
        authorLabel.text = "от \(nft.author)"
        priceValueLabel.text = "\(nft.price) ETH"
        ratingView.rating = nft.rating
        
        if let imageURL = nft.images.first {
            nftImageView.kf.setImage(with: imageURL)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        contentView.backgroundColor = .white
        selectionStyle = .none
        
        [nftImageView, nameLabel, authorLabel, priceLabel, priceValueLabel, ratingView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            nameLabel.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 23),
            nameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            ratingView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ratingView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ratingView.widthAnchor.constraint(equalToConstant: 68),
            ratingView.heightAnchor.constraint(equalToConstant: 12),
            
            authorLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 12),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            priceValueLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            priceValueLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceValueLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        ratingView.rating = 0
    }
}
