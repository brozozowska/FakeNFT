//
//  UserRatingCell.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import UIKit
import Kingfisher

final class UserRatingCell: UITableViewCell, ReuseIdentifying {
    private let numberLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 17, weight: .regular)
        l.textColor = .label
        return l
    }()

    private let profileRectView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 20
        return v
    }()

    private let avatarView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 14
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .systemGray3
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .label
        return l
    }()

    private let countLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .label
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        contentView.addSubview(numberLabel)
        contentView.addSubview(profileRectView)
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            profileRectView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileRectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            profileRectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            profileRectView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            profileRectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])

        profileRectView.addSubview(avatarView)
        profileRectView.addSubview(countLabel)
        profileRectView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            avatarView.centerYAnchor.constraint(equalTo: profileRectView.centerYAnchor),
            avatarView.leadingAnchor.constraint(equalTo: profileRectView.leadingAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 28),
            avatarView.heightAnchor.constraint(equalToConstant: 28),

            countLabel.centerYAnchor.constraint(equalTo: profileRectView.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: profileRectView.trailingAnchor, constant: -16),

            nameLabel.centerYAnchor.constraint(equalTo: profileRectView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -8)
        ])
    }

    func configure(rank: Int, user: User) {
        numberLabel.text = "\(rank)"
        nameLabel.text = user.name
        countLabel.text = "\(user.nftCount)"
        if let url = user.avatar {
            avatarView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.crop.circle.fill"))
        } else {
            avatarView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }
}
