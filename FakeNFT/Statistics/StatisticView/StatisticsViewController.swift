//
//  StatisticsViewController.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import UIKit

final class StatisticsViewController: UIViewController, LoadingView, ErrorView {

    private let viewModel: StatisticsViewModel

    private let tableView = UITableView(frame: .zero, style: .plain)
    internal let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var users: [User] = []

    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.backgroundColor = .systemBackground

        let sortImage = UIImage(named: "sort_icon")?.withRenderingMode(.alwaysOriginal)
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    image: sortImage,
                    style: .plain,
                    target: self,
                    action: #selector(showSort)
                )

        tableView.register(UserRatingCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.constraintEdges(to: view)
        activityIndicator.constraintCenters(to: view)

        bind()
        viewModel.load()
    }

    private func bind() {
        viewModel.onLoading = { [weak self] isLoading in
            isLoading ? self?.showLoading() : self?.hideLoading()
        }
        viewModel.onUsers = { [weak self] users in
            self?.users = users
            self?.tableView.reloadData()
        }
        viewModel.onError = { [weak self] error in
            self?.showError(error)
        }
    }

    @objc private func showSort() {
        let ac = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "По имени", style: .default) { [weak self] _ in
            self?.viewModel.changeSort(to: .byName)
        })
        ac.addAction(UIAlertAction(title: "По рейтингу", style: .default) { [weak self] _ in
            self?.viewModel.changeSort(to: .byRating)
        })
        ac.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        present(ac, animated: true)
    }
}

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 92 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserRatingCell = tableView.dequeueReusableCell()
        cell.configure(rank: indexPath.row + 1, user: users[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let vc = UserAssembly().build(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}
