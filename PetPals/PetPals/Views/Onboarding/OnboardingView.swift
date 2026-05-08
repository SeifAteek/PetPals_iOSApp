import SwiftUI

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String // Placeholder for actual illustration
    let isYellowBackground: Bool
}

struct OnboardingView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = OnboardingViewModel()
    
    let pages: [OnboardingPage] = [
        OnboardingPage(title: "Level up your pet parenting with PetPals", description: "", imageName: "pawprint.fill", isYellowBackground: false),
        OnboardingPage(title: "Discover Adoptable Pets", description: "Explore a network of compassionate shelters to find your new furry friend. Browse profiles, read heartwarming stories and take the first step towards welcoming a new family member.", imageName: "heart.text.square.fill", isYellowBackground: false),
        OnboardingPage(title: "Pet Care & Health", description: "Book your pet's boarding with ease.", imageName: "cross.case.fill", isYellowBackground: false),
        OnboardingPage(title: "Find Nearby Clinics & Services", description: "Locate trusted veterinary clinics, pet hospitals, and grooming services in your area.", imageName: "mappin.and.ellipse", isYellowBackground: false),
        OnboardingPage(title: "Track Your Pet's Health", description: "Stay on top of your pet's well-being with our health tracking feature.", imageName: "chart.line.uptrend.xyaxis", isYellowBackground: false)
    ]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Skip") {
                    viewModel.completeOnboarding(coordinator: coordinator)
                }
                .foregroundColor(.gray)
                .padding()
            }
            
            TabView(selection: $viewModel.currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            PaddingBottomView(viewModel: viewModel, coordinator: coordinator, totalPages: pages.count)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Illustration Placeholder
            Image(systemName: page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .foregroundColor(Theme.primary)
            
            Text(page.title)
                .font(Theme.Fonts.primaryFont(size: 28, weight: .bold))
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if !page.description.isEmpty {
                Text(page.description)
                    .font(Theme.Fonts.primaryFont(size: 16, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .background(page.isYellowBackground ? Theme.primary : Theme.background)
    }
}

struct PaddingBottomView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let coordinator: AppCoordinator
    let totalPages: Int
    
    var body: some View {
        VStack {
            if viewModel.currentPage == totalPages - 1 {
                PrimaryButton(title: "Get Started") {
                    viewModel.completeOnboarding(coordinator: coordinator)
                }
                .padding(.horizontal, 24)
            } else {
                PrimaryButton(title: "Next") {
                    withAnimation {
                        viewModel.nextPage()
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 32)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppCoordinator())
}
