import Foundation

struct PersonalityQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    var selected: String? = nil
}
