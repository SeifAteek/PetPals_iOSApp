import SwiftUI
import PhotosUI

struct CreateCommunityPostView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: CreateCommunityPostViewModel

    init(preselectedSubredditId: UUID? = nil) {
        _viewModel = StateObject(wrappedValue: CreateCommunityPostViewModel(preselectedSubredditId: preselectedSubredditId))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                PremiumScreenHeader(
                    eyebrow: L10n.societyEyebrow,
                    title: L10n.communityNewPost,
                    subtitle: L10n.communityNewPostSubtitle
                )

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    discussionPicker
                    postFields
                    photoSection

                    PrimaryButton(title: L10n.communityPublish, isLoading: viewModel.isSubmitting) {
                        viewModel.submit { post in
                            coordinator.pop()
                            coordinator.push(.communityPostDetail(postId: post.postId))
                        }
                    }
                    .padding(.horizontal, ScreenLayout.horizontalPadding)
                }

                if let err = viewModel.errorMessage {
                    Text(err)
                        .foregroundStyle(Theme.statusCritical)
                        .font(Theme.Fonts.body(Typography.caption))
                        .padding(.horizontal, ScreenLayout.horizontalPadding)
                }
            }
            .padding(.vertical, Spacing.sm)
        }
        .dismissKeyboardOnSwipe()
        .keyboardDoneToolbar()
        .petPalsScreenBackground()
        .navigationTitle(L10n.communityNewPost)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadSubreddits() }
        .onChange(of: viewModel.selectedItem) { _, item in
            viewModel.loadPreview(from: item)
        }
    }

    private var discussionPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(L10n.communityDiscussion)
                .font(Theme.Fonts.label(Typography.caption, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(viewModel.subreddits) { sub in
                        PremiumChip(
                            title: sub.name,
                            icon: sub.iconName,
                            isSelected: viewModel.selectedSubredditId == sub.subredditId
                        ) {
                            viewModel.selectedSubredditId = sub.subredditId
                        }
                    }
                }
            }
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    private var postFields: some View {
        VStack(spacing: Spacing.sm) {
            CustomTextField(placeholder: L10n.communityPostTitle, text: $viewModel.title)
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.communityPostBody)
                    .font(Theme.Fonts.label(Typography.caption, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                TextEditor(text: $viewModel.body)
                    .frame(minHeight: 140)
                    .font(Theme.Fonts.body(Typography.callout))
                    .padding(Spacing.xs)
                    .scrollContentBackground(.hidden)
                    .glassCard(cornerRadius: Radius.md, elevation: .resting)
            }
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(L10n.communityAddPhoto)
                .font(Theme.Fonts.label(Typography.caption, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)

            if let preview = viewModel.previewImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: preview)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))

                    Button {
                        Haptic.light()
                        viewModel.clearPhoto()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Theme.textPrimary.opacity(0.7))
                    }
                    .padding(Spacing.xs)
                }
            }

            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text(viewModel.previewImage == nil ? L10n.communityAttachPhoto : L10n.communityChangePhoto)
                        .font(Theme.Fonts.label(Typography.callout, weight: .semibold))
                }
                .foregroundStyle(Theme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .glassCard(cornerRadius: Radius.md, elevation: .resting)
            }
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }
}
