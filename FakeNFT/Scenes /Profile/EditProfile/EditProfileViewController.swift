import UIKit
import Combine

final class EditProfileViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let saveButtonHeight: CGFloat = 60
        static let saveButtonHorizontalInset: CGFloat = 16
        static let saveButtonBottomInset: CGFloat = 16
        static let avatarTopInset: CGFloat = 80
        static let avatarLeadingInset: CGFloat = 151.22
        static let avatarWidth: CGFloat = 72.57
        static let avatarHeight: CGFloat = 70
        static let nameTitleTopInset: CGFloat = 174
        static let titleHorizontalInset: CGFloat = 16
        static let textFieldTopSpacing: CGFloat = 8
        static let textFieldHeight: CGFloat = 44
        static let descriptionTitleTopInset: CGFloat = 278
        static let descriptionTextViewHeight: CGFloat = 132
        static let websiteTitleTopInset: CGFloat = 470
    }
    
    // MARK: - Properties
    private let viewModel: EditProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var avatarImageView: AvatarImageView = {
        let imageView = AvatarImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private lazy var nameTitleLabel: TitleLabel = {
        let label = TitleLabel()
        label.text = NSLocalizedString("EditProfile.name", comment: "Name")
        return label
    }()
    
    private lazy var nameTextField: EditProfileTextField = {
        let textField = EditProfileTextField()
        textField.placeholder = NSLocalizedString("EditProfile.namePlaceholder", comment: "Name")
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var descriptionTitleLabel: TitleLabel = {
        let label = TitleLabel()
        label.text = NSLocalizedString("EditProfile.description", comment: "Description")
        return label
    }()
    
    private lazy var descriptionTextView: EditProfileTextView = {
        let textView = EditProfileTextView()
        textView.delegate = self
        return textView
    }()
    
    private lazy var websiteTitleLabel: TitleLabel = {
        let label = TitleLabel()
        label.text = NSLocalizedString("EditProfile.website", comment: "Website")
        return label
    }()
    
    private lazy var websiteTextField: EditProfileTextField = {
        let textField = EditProfileTextField()
        textField.placeholder = NSLocalizedString("EditProfile.websitePlaceholder", comment: "Website")
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var saveButton: SaveButton = {
        let button = SaveButton()
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        setupInitialData()
        setupKeyboardDismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        let uiComponents: [UIView] = [
            avatarImageView,
            nameTitleLabel, nameTextField,
            descriptionTitleLabel, descriptionTextView,
            websiteTitleLabel, websiteTextField,
            saveButton
        ]
        
        uiComponents.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.saveButtonHorizontalInset),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.saveButtonHorizontalInset),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.saveButtonBottomInset),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.saveButtonHeight),
            
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.avatarTopInset),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.avatarLeadingInset),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarWidth),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarHeight),
            
            nameTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.nameTitleTopInset),
            nameTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleHorizontalInset),
            nameTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.titleHorizontalInset),
            
            nameTextField.topAnchor.constraint(equalTo: nameTitleLabel.bottomAnchor, constant: Constants.textFieldTopSpacing),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleHorizontalInset),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.titleHorizontalInset),
            nameTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.descriptionTitleTopInset),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleHorizontalInset),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.titleHorizontalInset),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: Constants.textFieldTopSpacing),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleHorizontalInset),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.titleHorizontalInset),
            descriptionTextView.heightAnchor.constraint(equalToConstant: Constants.descriptionTextViewHeight),
            
            websiteTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.websiteTitleTopInset),
            websiteTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleHorizontalInset),
            websiteTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.titleHorizontalInset),
            
            websiteTextField.topAnchor.constraint(equalTo: websiteTitleLabel.bottomAnchor, constant: Constants.textFieldTopSpacing),
            websiteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleHorizontalInset),
            websiteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.titleHorizontalInset),
            websiteTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
        ])
    }
    
    private func setupBindings() {
        viewModel.$saveButtonHidden
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hidden in
                self?.saveButton.isHidden = hidden
            }
            .store(in: &cancellables)
        
        viewModel.$avatarURL
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarURL in
                self?.loadAvatar(avatarURL)
            }
            .store(in: &cancellables)
    }
    
    private func setupInitialData() {
        nameTextField.text = viewModel.name
        descriptionTextView.text = viewModel.description
        websiteTextField.text = viewModel.website
        loadAvatar(viewModel.avatarURL)
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func loadAvatar(_ urlString: String) {
        guard !urlString.isEmpty else {
            avatarImageView.setPlaceholder()
            return
        }
        
        let fullURLString = urlString.hasPrefix("http") ? urlString : "\(RequestConstants.baseURL)\(urlString)"
        
        if let url = URL(string: fullURLString) {
            avatarImageView.loadImage(from: url)
        } else {
            avatarImageView.setPlaceholder()
        }
    }
    
    private func showPhotoActionSheet() {
        let actionSheet = UIAlertController(
            title: NSLocalizedString("EditProfile.photoProfile", comment: "Profile photo"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let changeAction = UIAlertAction(
            title: NSLocalizedString("EditProfile.changePhoto", comment: "Change photo"),
            style: .default
        ) { [weak self] _ in
            self?.showPhotoURLAlert()
        }
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("EditProfile.deletePhoto", comment: "Delete photo"),
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel.updateAvatar("")
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("EditProfile.cancel", comment: "Cancel"),
            style: .cancel
        )
        
        actionSheet.addAction(changeAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    private func showPhotoURLAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Ссылка на фото", comment: "Photo URL"),
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("Введите ссылку на фото", comment: "Enter photo URL")
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
        }
        
        let saveAction = UIAlertAction(
            title: NSLocalizedString("Сохранить", comment: "Save"),
            style: .default
        ) { [weak self] _ in
            guard let urlString = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !urlString.isEmpty else { return }
            
            self?.viewModel.updateAvatar(urlString)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Отмена", comment: "Cancel"),
            style: .cancel
        )
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showUnsavedChangesAlert() {
        let alert = UIAlertController(
            title: "Уверены, что хотите выйти?",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Остаться", style: .default))
        alert.addAction(UIAlertAction(title: "Выйти", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func backButtonTapped() {
        if viewModel.hasChanges {
            showUnsavedChangesAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func saveTapped() {
        viewModel.saveProfile { [weak self] success in
            if success {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showAlert(message: NSLocalizedString("EditProfile.saveError", comment: "Save error"))
            }
        }
    }
    
    @objc private func avatarTapped() {
        showPhotoActionSheet()
    }
    
    @objc private func textFieldDidChange() {
        viewModel.name = nameTextField.text ?? ""
        viewModel.website = websiteTextField.text ?? ""
    }
}

// MARK: - UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditProfileViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.description = textView.text
    }
}
