import UIKit
import WebKit

// MARK: - WebViewController
final class WebViewController: UIViewController, WKNavigationDelegate {

    // MARK: - UI
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Properties
    private let url: URL

    // MARK: - Init
    init(url: URL, title: String? = nil) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupHierarchy()
        setupConstraints()
        setupWebView()
        loadRequest()
    }

    // MARK: - Setup
    private func setupHierarchy() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)
        view.addSubview(activityIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupWebView() {
        webView.navigationDelegate = self
    }

    private func loadRequest() {
        activityIndicator.startAnimating()
        webView.load(URLRequest(url: url))
    }

    // MARK: - WKNavigationDelegate
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        activityIndicator.stopAnimating()
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        activityIndicator.stopAnimating()
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        activityIndicator.stopAnimating()
    }
}
