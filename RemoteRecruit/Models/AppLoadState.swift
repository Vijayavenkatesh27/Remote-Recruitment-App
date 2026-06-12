import Foundation

enum AppLoadState: Equatable {
    case idle
    case loading
    case success
    case empty
    case failed(String)
}
