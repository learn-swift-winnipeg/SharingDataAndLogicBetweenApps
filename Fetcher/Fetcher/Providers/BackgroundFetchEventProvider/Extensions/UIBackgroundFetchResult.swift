import UIKit

extension UIBackgroundFetchResult: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noData: return ".noData"
        case .newData: return ".newData"
        case .failed: return ".failed"
        }
    }
}
