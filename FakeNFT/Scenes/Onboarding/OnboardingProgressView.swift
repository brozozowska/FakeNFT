import UIKit

final class OnboardingProgressView: UIView {
    
    // MARK: - Properties
    
    private var progressLayers: [CAShapeLayer] = []
    private let lineHeight: CGFloat = 3
    private let lineSpacing: CGFloat = 4
    
    var numberOfPages: Int = 0 {
        didSet {
            setupProgressLayers()
        }
    }
    
    var currentPage: Int = 0 {
        didSet {
            updateProgressAppearance()
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        backgroundColor = .clear
    }
    
    private func setupProgressLayers() {
        progressLayers.forEach { $0.removeFromSuperlayer() }
        progressLayers.removeAll()
        
        for i in 0..<numberOfPages {
            let layer = CAShapeLayer()
            layer.cornerRadius = lineHeight / 2
            layer.masksToBounds = true
            
            if i == currentPage {
                layer.backgroundColor = UIColor.white.cgColor
            } else {
                layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
            }
            
            self.layer.addSublayer(layer)
            progressLayers.append(layer)
        }
        
        setNeedsLayout()
    }
    
    private func updateProgressAppearance() {
        for (index, layer) in progressLayers.enumerated() {
            if index == currentPage {
                layer.backgroundColor = UIColor.white.cgColor
            } else {
                layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !progressLayers.isEmpty else { return }
        
        let totalWidth = bounds.width
        let totalSpacing = CGFloat(numberOfPages - 1) * lineSpacing
        let lineWidth = (totalWidth - totalSpacing) / CGFloat(numberOfPages)
        
        for (index, layer) in progressLayers.enumerated() {
            let xPosition = CGFloat(index) * (lineWidth + lineSpacing)
            layer.frame = CGRect(
                x: xPosition,
                y: 0,
                width: lineWidth,
                height: lineHeight
            )
        }
    }
}
