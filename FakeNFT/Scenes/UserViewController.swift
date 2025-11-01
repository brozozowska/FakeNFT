//
//  UserViewController.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import UIKit
import WebKit
import Kingfisher

final class UserViewController: UIViewController {

    private let viewModel: UserViewModel

    private let avatar = UIImageView()
    private let nameLabel = UILabel()
    private let bioLabel = UILabel()
    private let siteButton = UIButton(type: .system)

    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        avatar.layer.cornerRadius = 36; avatar.clipsToBounds = true
        avatar.backgroundColor = .tertiarySystemFill
        nameLabel.font = .headline2
        bioLabel.font = .bodyRegular; bioLabel.numberOfLines = 0

        siteButton.setTitle("Перейти на сайт пользователя", for: .normal)
        siteButton.addTarget(self, action: #selector(openSite), for: .touchUpInside)

        [avatar, nameLabel, bioLabel, siteButton].forEach(view.addSubview)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        siteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            avatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatar.widthAnchor.constraint(equalToConstant: 72),
            avatar.heightAnchor.constraint(equalToConstant: 72),

            nameLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            bioLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 16),
            bioLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bioLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            siteButton.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 16),
            siteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            siteButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        bind()
        viewModel.viewDidLoad()
    }

    private func bind() {
        viewModel.onNameBio = { [weak self] name, bio in
            self?.nameLabel.text = name
            self?.bioLabel.text = bio
        }
        viewModel.onAvatar = { [weak self] url in
            if let url {
                self?.avatar.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle.fill"))
            } else {
                self?.avatar.image = UIImage(systemName: "person.circle.fill")
            }
        }
        viewModel.onWebsiteVisible = { [weak self] visible in
            self?.siteButton.isHidden = !visible
        }
    }

    @objc private func openSite() {
        guard let url = viewModel.website else { return }
        let web = WKWebView()
        let vc = UIViewController()
        vc.view = web
        vc.title = "Сайт"
        web.load(URLRequest(url: url))
        navigationController?.pushViewController(vc, animated: true)
    }
}
