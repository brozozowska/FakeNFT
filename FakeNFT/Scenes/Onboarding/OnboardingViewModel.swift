import Foundation
import Combine

final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentPage: Int = .zero
    @Published var slides: [OnboardingSlide] = []
    
    // MARK: - Init
    
    init() {
        setupSlides()
    }
    
    // MARK: - Public Methods
    
    func nextPage() {
        if currentPage < slides.count - 1 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    func getSlide(at index: Int) -> OnboardingSlide? {
        guard index >= 0 && index < slides.count else { return nil }
        return slides[index]
    }
    
    // MARK: - Private Methods
    
    private func setupSlides() {
        slides = [
            OnboardingSlide(
                imageName: "image1",
                title: NSLocalizedString("Onboarding.slide1.title", comment: "First slide title"),
                description: NSLocalizedString("Onboarding.slide1.description", comment: "First slide description"),
                isLastSlide: false
            ),
            OnboardingSlide(
                imageName: "image2",
                title: NSLocalizedString("Onboarding.slide2.title", comment: "Second slide title"),
                description: NSLocalizedString("Onboarding.slide2.description", comment: "Second slide description"),
                isLastSlide: false
            ),
            OnboardingSlide(
                imageName: "image3",
                title: NSLocalizedString("Onboarding.slide3.title", comment: "Third slide title"),
                description: NSLocalizedString("Onboarding.slide3.description", comment: "Third slide description"),
                isLastSlide: true
            )
        ]
    }
}
