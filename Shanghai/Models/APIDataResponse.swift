import Foundation

struct APIDataResponse<T: Decodable>: Decodable {
    let data: T
}
