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
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var nftCount: Int = 0

    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.hidesBackButton = true
        let backImage = UIImage(named: "back_icon")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )

        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 35
        avatar.backgroundColor = .tertiarySystemFill
        avatar.image = UIImage(systemName: "person.crop.circle.fill")

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .label

        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.font = .systemFont(ofSize: 13, weight: .regular)
        bioLabel.textColor = .label
        bioLabel.numberOfLines = 4

        siteButton.translatesAutoresizingMaskIntoConstraints = false
        siteButton.setTitle("Перейти на сайт пользователя", for: .normal)
        siteButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        siteButton.setTitleColor(.label, for: .normal)
        siteButton.layer.cornerRadius = 16
        siteButton.layer.borderWidth = 1
        siteButton.layer.borderColor = UIColor.label.cgColor
        siteButton.addTarget(self, action: #selector(openSite), for: .touchUpInside)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserProfileCollectionCell.self, forCellReuseIdentifier: "UserProfileCollectionCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = 54
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear

        view.addSubview(avatar)
        view.addSubview(nameLabel)
        view.addSubview(bioLabel)
        view.addSubview(siteButton)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatar.widthAnchor.constraint(equalToConstant: 70),
            avatar.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.heightAnchor.constraint(equalToConstant: 28),

            bioLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 20),
            bioLabel.leadingAnchor.constraint(equalTo: avatar.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            siteButton.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 28),
            siteButton.leadingAnchor.constraint(equalTo: avatar.leadingAnchor),
            siteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            siteButton.heightAnchor.constraint(equalToConstant: 40),

            tableView.topAnchor.constraint(equalTo: siteButton.bottomAnchor, constant: 41),
            tableView.leadingAnchor.constraint(equalTo: avatar.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 54)
        ])

        bind()
        viewModel.viewDidLoad()
      
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    private func bind() {
        viewModel.onNameBio = { [weak self] name, bio in
            self?.nameLabel.text = name
            self?.bioLabel.text = bio
        }
        viewModel.onAvatar = { [weak self] url in
            if let url {
                self?.avatar.kf.setImage(with: url, placeholder: UIImage(systemName: "person.crop.circle.fill"))
            } else {
                self?.avatar.image = UIImage(systemName: "person.crop.circle.fill")
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

private final class UserProfileCollectionCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label

        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = .tertiaryLabel
        chevron.contentMode = .scaleAspectFit

        contentView.addSubview(titleLabel)
        contentView.addSubview(chevron)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(count: Int) {
        titleLabel.text = "Коллекция NFT (\(count))"
        titleLabel.textColor = count > 0 ? .label : .systemGray2
        chevron.tintColor = count > 0 ? .tertiaryLabel : .systemGray3
    }
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reuseID = "UserProfileCollectionCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseID,
                                                       for: indexPath) as? UserProfileCollectionCell
        else {
            // fallback, чтобы не упасть
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }

        cell.configure(count: nftCount)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard nftCount > 0 else { return }
        let vc = StatisticsCollectionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

