//
//  StatisticsCustomNavBar.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/17/25.
//

import UIKit

final class StatisticsCustomNavBar: UIView {

    // MARK: - Public UI

    let sortButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        b.tintColor = .label
        return b
    }()

    let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .label
        return b
    }()

    let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .label
        l.textAlignment = .center
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .background   

        addSubview(backButton)
        addSubview(sortButton)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            // back
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),

            // sort
            sortButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            sortButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sortButton.widthAnchor.constraint(equalToConstant: 24),
            sortButton.heightAnchor.constraint(equalToConstant: 24),

            // title
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Configuration helpers

    func setTitle(_ text: String) {
        titleLabel.text = text
    }

    func setBackButtonHidden(_ hidden: Bool) {
        backButton.isHidden = hidden
    }

    func setSortButtonHidden(_ hidden: Bool) {
        sortButton.isHidden = hidden
    }
}
