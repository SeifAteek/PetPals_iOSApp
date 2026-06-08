import Foundation

/// Centralized user-facing copy. Keys in `en.lproj`, `ar.lproj`, `fr.lproj` `Localizable.strings`.
enum L10n {
    private static func tr(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: AppLanguage.localizedBundle, value: key, comment: "")
    }

    // MARK: - Tabs
    static var tabHome: String { tr("tab_home") }
    static var tabDiscover: String { tr("tab_discover") }
    static var tabSociety: String { tr("tab_society") }
    /// Tab bar label (Society).
    static var tabCommunity: String { tabSociety }
    static var tabCare: String { tr("tab_care") }
    static var tabYou: String { tr("tab_you") }

    // MARK: - You hub
    static var yourSpace: String { tr("your_space") }
    static var petParentDefault: String { tr("pet_parent_default") }
    static var yourSubtitleShort: String { tr("your_subtitle_short") }
    static var myPets: String { tr("my_pets") }
    static var messages: String { tr("messages") }
    static var clinicsShelters: String { tr("clinics_shelters") }
    static var giveBack: String { tr("give_back") }
    static var campaignsDonations: String { tr("campaigns_donations") }
    static var profileSettingsSubtitle: String { tr("profile_settings_subtitle") }
    static var memberSince: String { tr("member_since") }
    static var managePetFamily: String { tr("manage_pet_family") }
    static var addFirstCompanion: String { tr("add_first_companion") }

    static func companionsCount(_ count: Int) -> String {
        let key = count == 1 ? "companion_count_fmt" : "companions_count_fmt"
        return String(format: tr(key), locale: AppLanguage.locale, count)
    }

    // MARK: - Settings
    static var editProfile: String { tr("edit_profile") }
    static var displayName: String { tr("display_name") }
    static var email: String { tr("email") }
    static var phone: String { tr("phone") }
    static var saveChanges: String { tr("save_changes") }
    static var account: String { tr("account") }
    static var myActivity: String { tr("my_activity") }
    static var donationHistory: String { tr("donation_history") }
    static var preferences: String { tr("preferences") }
    static var darkMode: String { tr("dark_mode") }
    static var logOut: String { tr("log_out") }

    // MARK: - Language
    static var language: String { tr("language") }
    static var languageSystem: String { tr("language_system") }
    static var languageEnglish: String { tr("language_english") }
    static var languageArabic: String { tr("language_arabic") }
    static var languageFrench: String { tr("language_french") }

    // MARK: - Onboarding
    static var skip: String { tr("onboarding_skip") }
    static var onboardingContinue: String { tr("onboarding_continue") }
    static var onboardingGetStarted: String { tr("onboarding_get_started") }
    static var onboardingWelcomeEyebrow: String { tr("onboarding_welcome_eyebrow") }
    static var onboardingWelcomeTitle: String { tr("onboarding_welcome_title") }
    static var onboardingWelcomeDesc: String { tr("onboarding_welcome_desc") }
    static var onboardingDiscoverEyebrow: String { tr("onboarding_discover_eyebrow") }
    static var onboardingDiscoverTitle: String { tr("onboarding_discover_title") }
    static var onboardingDiscoverDesc: String { tr("onboarding_discover_desc") }
    static var onboardingCareEyebrow: String { tr("onboarding_care_eyebrow") }
    static var onboardingCareTitle: String { tr("onboarding_care_title") }
    static var onboardingCareDesc: String { tr("onboarding_care_desc") }
    static var onboardingNearbyEyebrow: String { tr("onboarding_nearby_eyebrow") }
    static var onboardingNearbyTitle: String { tr("onboarding_nearby_title") }
    static var onboardingNearbyDesc: String { tr("onboarding_nearby_desc") }
    static var onboardingWellnessEyebrow: String { tr("onboarding_wellness_eyebrow") }
    static var onboardingWellnessTitle: String { tr("onboarding_wellness_title") }
    static var onboardingWellnessDesc: String { tr("onboarding_wellness_desc") }

    // MARK: - Auth
    static var premiumCareTagline: String { tr("premium_care_tagline") }
    static var logIn: String { tr("log_in") }
    static var signUp: String { tr("sign_up") }
    static var createAccount: String { tr("create_account") }
    static var orContinueWith: String { tr("or_continue_with") }
    static var firstName: String { tr("first_name") }
    static var lastName: String { tr("last_name") }
    static var password: String { tr("password") }
    static var confirmPassword: String { tr("confirm_password") }

    // MARK: - Home
    static var goodMorning: String { tr("good_morning") }
    static var goodAfternoon: String { tr("good_afternoon") }
    static var goodEvening: String { tr("good_evening") }
    static var hello: String { tr("hello") }
    static var petLover: String { tr("pet_lover") }
    static var homeHeroTitle: String { tr("home_hero_title") }
    static var homeHeroDesc: String { tr("home_hero_desc") }
    static var findAPet: String { tr("find_a_pet") }
    static var petCare: String { tr("pet_care") }
    static var searchPlaceholderHome: String { tr("search_placeholder_home") }
    static var recommendedAdoption: String { tr("recommended_adoption") }
    static var seeAll: String { tr("see_all") }
    static var services: String { tr("services") }
    static var nearbyVets: String { tr("nearby_vets") }
    static var viewAll: String { tr("view_all") }
    static var veterinary: String { tr("veterinary") }
    static var grooming: String { tr("grooming") }
    static var petShop: String { tr("pet_shop") }
    static var boarding: String { tr("boarding") }
    static var readyForLove: String { tr("ready_for_love") }
    static var yearsShort: String { tr("years_short") }
    static var noRecommendedListings: String { tr("no_recommended_listings") }
    static var noRecommendedListingsDesc: String { tr("no_recommended_listings_desc") }

    static func matchScorePercent(_ score: Int) -> String {
        String(format: tr("match_score_fmt"), locale: AppLanguage.locale, score)
    }

    static func petAgeYears(_ age: Int) -> String {
        String(format: tr("pet_age_years_fmt"), locale: AppLanguage.locale, age)
    }

    // MARK: - Profile setup
    static var profileSetupEyebrow: String { tr("profile_setup_eyebrow") }
    static var profileSetupTitle: String { tr("profile_setup_title") }
    static var profileSetupSubtitle: String { tr("profile_setup_subtitle") }
    static var profileSetupContinue: String { tr("profile_setup_continue") }
    static var profileSetupRequiredFields: String { tr("profile_setup_required_fields") }
    static var profileNamePlaceholder: String { tr("profile_name_placeholder") }
    static var profileEmailPlaceholder: String { tr("profile_email_placeholder") }
    static var profilePhonePlaceholder: String { tr("profile_phone_placeholder") }
    static var sessionExpired: String { tr("session_expired") }

    // MARK: - Personality test
    static var personalitySetupEyebrow: String { tr("personality_setup_eyebrow") }
    static var personalitySetupTitle: String { tr("personality_setup_title") }
    static var personalitySetupSubtitle: String { tr("personality_setup_subtitle") }
    static var personalityTestTitle: String { tr("personality_test_title") }
    static var personalityFinish: String { tr("personality_finish") }
    static var cancel: String { tr("cancel") }
    static var back: String { tr("back") }

    static func personalityQuestionProgress(_ current: Int, _ total: Int) -> String {
        String(format: tr("personality_question_progress_fmt"), locale: AppLanguage.locale, current, total)
    }

    // MARK: - Discover
    static var discoverEyebrow: String { tr("discover_eyebrow") }
    static var adoptWithHeart: String { tr("adopt_with_heart") }
    static var discoverSubtitle: String { tr("discover_subtitle") }
    static var searchPetsPlaceholder: String { tr("search_pets_placeholder") }
    static var noPetsFound: String { tr("no_pets_found") }
    static var noPetsFoundDesc: String { tr("no_pets_found_desc") }
    static var findingCompanions: String { tr("finding_companions") }

    // MARK: - Care hub
    static var wellness: String { tr("wellness") }
    static var petCareTitle: String { tr("pet_care_title") }
    static var careSubtitle: String { tr("care_subtitle") }
    static var dailyPetTips: String { tr("daily_pet_tips") }
    static var topVeterinarians: String { tr("top_veterinarians") }

    // MARK: - Charity
    static var impact: String { tr("impact") }
    static var giveBackTitle: String { tr("give_back_title") }
    static var giveBackSubtitle: String { tr("give_back_subtitle") }
    static var yourImpact: String { tr("your_impact") }
    static var donatedAcrossFmt: String { tr("donated_across_fmt") }
    static var donationHistoryTitle: String { tr("donation_history_title") }
    static var noDonationsYet: String { tr("no_donations_yet") }
    static var donateNow: String { tr("donate_now") }
    static var noActiveCampaigns: String { tr("no_active_campaigns") }
    static var noActiveCampaignsDesc: String { tr("no_active_campaigns_desc") }

    // MARK: - Messages
    static var inboxQuiet: String { tr("inbox_quiet") }
    static var inboxQuietDesc: String { tr("inbox_quiet_desc") }

    // MARK: - My pets
    static var add: String { tr("add") }
    static var noPetsYet: String { tr("no_pets_yet") }
    static var noPetsYetDesc: String { tr("no_pets_yet_desc") }
    static var addYourPet: String { tr("add_your_pet") }

    // MARK: - Reviews
    static var reviewsRatings: String { tr("reviews_ratings") }
    static var loadingReviews: String { tr("loading_reviews") }
    static var yourRating: String { tr("your_rating") }
    static var reviewPlaceholder: String { tr("review_placeholder") }
    static var submitReview: String { tr("submit_review") }
    static var noReviewsYet: String { tr("no_reviews_yet") }
    static var reviewerDefault: String { tr("reviewer_default") }
    static func reviewsCount(_ count: Int) -> String {
        let key = count == 1 ? "review_count_fmt" : "reviews_count_fmt"
        return String(format: tr(key), locale: AppLanguage.locale, count)
    }

    // MARK: - Categories
    static var all: String { tr("all") }
    static var dogs: String { tr("dogs") }
    static var cats: String { tr("cats") }
    static var birds: String { tr("birds") }
    static var rabbits: String { tr("rabbits") }

    // MARK: - Society (community)
    static var societyEyebrow: String { tr("society_eyebrow") }
    static var communityEyebrow: String { societyEyebrow }
    static var communityTitle: String { tr("community_title") }
    static var communitySubtitle: String { tr("community_subtitle") }
    static var communityNoPosts: String { tr("community_no_posts") }
    static var communityNoPostsDesc: String { tr("community_no_posts_desc") }
    static var communityDiscussion: String { tr("community_discussion") }
    static var communityNewPost: String { tr("community_new_post") }
    static var communityNewPostSubtitle: String { tr("community_new_post_subtitle") }
    static var communityPostTitle: String { tr("community_post_title") }
    static var communityPostBody: String { tr("community_post_body") }
    static var communityPublish: String { tr("community_publish") }
    static var communityCommentsTitle: String { tr("community_comments_title") }
    static var communityNoComments: String { tr("community_no_comments") }
    static var communityCommentPlaceholder: String { tr("community_comment_placeholder") }
    static var communitySignInToVote: String { tr("community_sign_in_vote") }
    static var communitySignInToComment: String { tr("community_sign_in_comment") }
    static var communitySignInToPost: String { tr("community_sign_in_post") }
    static var communityPostFieldsRequired: String { tr("community_post_fields_required") }
    static var communityPostTitleRequired: String { tr("community_post_title_required") }
    static var communityPickDiscussion: String { tr("community_pick_discussion") }
    static var communityAddPhoto: String { tr("community_add_photo") }
    static var communityAttachPhoto: String { tr("community_attach_photo") }
    static var communityChangePhoto: String { tr("community_change_photo") }

    static func communityCommentsCount(_ count: Int) -> String {
        String(format: tr("community_comments_count_fmt"), locale: AppLanguage.locale, count)
    }

    // MARK: - Common
    static var done: String { tr("done") }
    static var close: String { tr("close") }
    static var loading: String { tr("loading") }

    // MARK: - Shop / orders (existing)
    static var myOrders: String { tr("my_orders") }
    static var noOrdersYet: String { tr("no_orders_yet") }
    static var pastOrdersAppearHere: String { tr("past_orders_appear_here") }
    static var loadingOrders: String { tr("loading_orders") }
    static var shoppingCart: String { tr("shopping_cart") }
    static var cartEmpty: String { tr("cart_empty") }
    static var total: String { tr("total") }
    static var checkout: String { tr("checkout") }
    static var cartMixedShopsError: String { tr("cart_mixed_shops_error") }
    static var cartMissingShopError: String { tr("cart_missing_shop_error") }
    static var checkoutNavTitle: String { tr("checkout_nav_title") }
    static var selectPaymentMethod: String { tr("select_payment_method") }
    static var bookingSummary: String { tr("booking_summary") }
    static var payPrefix: String { tr("pay_prefix") }
    static var paymentSuccessful: String { tr("payment_successful") }
    static var paymentSuccessMessage: String { tr("payment_success_message") }
    static var cardHolder: String { tr("card_holder") }
    static var expires: String { tr("expires") }
    static var receiptGenerated: String { tr("receipt_generated") }
    static var billReceipt: String { tr("bill_receipt") }
    static var savedToDatabase: String { tr("saved_to_database") }
    static var officialReceipt: String { tr("official_receipt") }
    static var salesBill: String { tr("sales_bill") }
    static var receiptNo: String { tr("receipt_no") }
    static var channel: String { tr("channel") }
    static var billedTo: String { tr("billed_to") }
    static var payment: String { tr("payment") }
    static var item: String { tr("item") }
    static var qty: String { tr("qty") }
    static var unit: String { tr("unit") }
    static var amount: String { tr("amount") }
    static var subtotal: String { tr("subtotal") }
    static var discount: String { tr("discount") }
    static var totalPaid: String { tr("total_paid") }
    static var generatedPetpals: String { tr("generated_petpals") }
    static var shareReceipt: String { tr("share_receipt") }
    static var viewReceipt: String { tr("view_receipt") }
    static var orderDetails: String { tr("order_details") }
    static var noReceiptYet: String { tr("no_receipt_yet") }
    static var onlineChannel: String { tr("channel_online") }
    static var inStoreChannel: String { tr("channel_in_store") }
    static var settings: String { tr("settings") }
    static var bookAppointment: String { tr("book_appointment") }
    static var bookNow: String { tr("book_now") }
    static var servicesPricing: String { tr("services_pricing") }
    static var perDay: String { tr("per_day") }
    static var startingFromPerDay: String { tr("starting_from_per_day") }
    static var boardingSamplePrice: String { tr("boarding_sample_price") }
    static var checkoutMissingContext: String { tr("checkout_missing_context") }
    static var userNotAuthenticated: String { tr("user_not_authenticated") }
    static var boardingBookingSummary: String { tr("boarding_booking_summary") }

    static func thankYouShoppingFormatted(shopName: String) -> String {
        String(format: tr("thank_you_shopping_fmt"), locale: AppLanguage.locale, shopName)
    }

    static func donatedAcross(campaignCount: Int) -> String {
        String(format: tr("donated_across_fmt"), locale: AppLanguage.locale, campaignCount)
    }
}
