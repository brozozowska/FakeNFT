import UIKit
import Combine

final class EditProfileViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let saveButtonHeight: CGFloat = 60
        static let saveButtonHorizontalInset: CGFloat = 16
        static let saveButtonBottomInset: CGFloat = 16
        static let avatarTopInset: CGFloat = 80
        static let avatarSize: CGSize = CGSize(width: 72.566, height: 70)
        static let nameTitleTopInset: CGFloat = 174
        static let titleHorizontalInset: CGFloat = 16
        static let textFieldTopSpacing: CGFloat = 8
        static let textFieldHeight: CGFloat = 44
        static let descriptionTitleTopInset: CGFloat = 24
        static let descriptionTextViewHeight: CGFloat = 132
        static let websiteTitleTopInset: CGFloat = 24
        static let contentBottomInset: CGFloat = 100
    }
    
    // MARK: - Properties
    private let viewModel: EditProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    private var activeField: UIView?
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var avatarImageView: AvatarWithCameraView = {
        let imageView = AvatarWithCameraView()
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
        setupKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        removeKeyboardObservers()
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
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let uiComponents: [UIView] = [
            avatarImageView,
            nameTitleLabel, nameTextField,
            descriptionTitleLabel, descriptionTextView,
            websiteTitleLabel, websiteTextField,
            saveButton
        ]
        
        uiComponents.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.avatarTopInset),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize.width),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize.height),
            
            nameTitleLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constants.nameTitleTopInset - Constants.avatarTopInset - Constants.avatarSize.height),
            nameTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.titleHorizontalInset),
            nameTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.titleHorizontalInset),
            
            nameTextField.topAnchor.constraint(equalTo: nameTitleLabel.bottomAnchor, constant: Constants.textFieldTopSpacing),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.titleHorizontalInset),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.titleHorizontalInset),
            nameTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: Constants.descriptionTitleTopInset),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.titleHorizontalInset),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.titleHorizontalInset),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: Constants.textFieldTopSpacing),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.titleHorizontalInset),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.titleHorizontalInset),
            descriptionTextView.heightAnchor.constraint(equalToConstant: Constants.descriptionTextViewHeight),
            
            websiteTitleLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: Constants.websiteTitleTopInset),
            websiteTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.titleHorizontalInset),
            websiteTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.titleHorizontalInset),
            
            websiteTextField.topAnchor.constraint(equalTo: websiteTitleLabel.bottomAnchor, constant: Constants.textFieldTopSpacing),
            websiteTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.titleHorizontalInset),
            websiteTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.titleHorizontalInset),
            websiteTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            saveButton.topAnchor.constraint(equalTo: websiteTextField.bottomAnchor, constant: 202),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.saveButtonHorizontalInset),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.saveButtonHorizontalInset),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.saveButtonHeight),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.contentBottomInset)
        ])
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupBindings() {
        viewModel.$saveButtonHidden
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hidden in
                self?.saveButton.isHidden = hidden
            }
            .store(in: &cancellables)
    }
    
    private func setupInitialData() {
        nameTextField.text = viewModel.name
        descriptionTextView.text = viewModel.description
        websiteTextField.text = viewModel.website
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
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("EditProfile.cancel", comment: "Cancel"),
            style: .cancel
        )
        
        actionSheet.addAction(changeAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    private func showPhotoURLAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("EditProfile.photoURL.title", comment: "Photo URL"),
            message: NSLocalizedString("EditProfile.photoURL.message", comment: "This will only update the avatar URL in your profile"),
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("EditProfile.photoURL.placeholder", comment: "Enter photo URL")
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
        }
        
        let saveAction = UIAlertAction(
            title: NSLocalizedString("EditProfile.photoURL.save", comment: "Save"),
            style: .default
        ) { [weak self] _ in
            guard let urlString = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !urlString.isEmpty else { return }
            
            self?.viewModel.updateAvatar(urlString)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("EditProfile.photoURL.cancel", comment: "Cancel"),
            style: .cancel
        )
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("General.ok", comment: "OK"),
            style: .default
        ))
        present(alert, animated: true)
    }
    
    private func showUnsavedChangesAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("EditProfile.unsavedChanges.title", comment: "Unsaved changes title"),
            message: NSLocalizedString("EditProfile.unsavedChanges.message", comment: "You have unsaved changes"),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("EditProfile.unsavedChanges.stay", comment: "Stay"),
            style: .default
        ))
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("EditProfile.unsavedChanges.exit", comment: "Exit"),
            style: .default
        ) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let activeField = activeField else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var visibleRect = activeField.convert(activeField.bounds, to: scrollView)
        visibleRect = visibleRect.insetBy(dx: 0, dy: -20)
        
        scrollView.scrollRectToVisible(visibleRect, animated: true)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        if viewModel.hasChanges {
            showUnsavedChangesAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func saveTapped() {
        view.endEditing(true)
        viewModel.saveProfile { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.showAlert(message: NSLocalizedString("EditProfile.saveError", comment: "Save error"))
                }
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeField = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeField = nil
    }
    
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
