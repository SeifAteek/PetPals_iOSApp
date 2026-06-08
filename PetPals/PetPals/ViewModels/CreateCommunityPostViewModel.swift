import Foundation
import Combine
import SwiftUI
import UIKit
import PhotosUI

@MainActor
final class CreateCommunityPostViewModel: ObservableObject {
    @Published var subreddits: [CommunitySubreddit] = []
    @Published var selectedSubredditId: UUID?
    @Published var title = ""
    @Published var body = ""
    @Published var selectedItem: PhotosPickerItem?
    @Published var previewImage: UIImage?
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    private let communityService: CommunityServiceProtocol
    private let authService: AuthServiceProtocol

    init(
        preselectedSubredditId: UUID? = nil,
        communityService: CommunityServiceProtocol = DependencyContainer.shared.communityService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.selectedSubredditId = preselectedSubredditId
        self.communityService = communityService
        self.authService = authService
    }

    func loadSubreddits() {
        isLoading = true
        Task {
            do {
                subreddits = try await communityService.fetchSubreddits()
                if selectedSubredditId == nil {
                    selectedSubredditId = subreddits.first?.subredditId
                }
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func loadPreview(from item: PhotosPickerItem?) {
        guard let item else {
            previewImage = nil
            return
        }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                previewImage = image
            }
        }
    }

    func clearPhoto() {
        selectedItem = nil
        previewImage = nil
    }

    func submit(onSuccess: @escaping (CommunityPost) -> Void) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = L10n.communityPostTitleRequired
            return
        }
        guard !trimmedBody.isEmpty || previewImage != nil else {
            errorMessage = L10n.communityPostFieldsRequired
            return
        }
        guard let subredditId = selectedSubredditId else {
            errorMessage = L10n.communityPickDiscussion
            return
        }

        isSubmitting = true
        errorMessage = nil
        Task {
            do {
                guard let user = try await authService.getCurrentUser() else {
                    errorMessage = L10n.communitySignInToPost
                    isSubmitting = false
                    return
                }

                var imageUrl: String?
                if let previewImage,
                   let data = previewImage.jpegData(compressionQuality: 0.85) {
                    let fileName = "\(user.userId.uuidString.lowercased())-\(Int(Date().timeIntervalSince1970)).jpg"
                    imageUrl = try await communityService.uploadPostImage(data: data, fileName: fileName)
                }

                let post = try await communityService.createPost(
                    subredditId: subredditId,
                    userId: user.userId,
                    title: trimmedTitle,
                    body: trimmedBody,
                    imageUrl: imageUrl
                )
                isSubmitting = false
                onSuccess(post)
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}
