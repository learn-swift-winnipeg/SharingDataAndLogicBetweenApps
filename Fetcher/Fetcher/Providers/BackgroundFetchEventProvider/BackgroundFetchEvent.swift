import UIKit

public struct BackgroundFetchEvent: Codable, Hashable {
    public let occuredAt: Date
    public let returnedResult: UIBackgroundFetchResult
}

extension UIBackgroundFetchResult: Codable {}
