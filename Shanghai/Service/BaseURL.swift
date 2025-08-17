import Foundation

enum BaseURL {
    static var baseURLString: String {
        Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
    }
}
