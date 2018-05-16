import Foundation
import UIKit

class BackgroundFetchEventProvider {
    
    // MARK: - Stored Properties
    
    struct UserDefaultKeys {
        static let backgroundFetchEvents = "backgroundFetchEvents"
        static let backgroundFetchResultToReturn = "backgroundFetchResultToReturn"
    }
    private let userDefaults = UserDefaults.standard
    
    // TODO: Attempt to replace UserDefaults storage with NSFileCoordinator and NSFilePresenter implementation to enable "notification" for file changes from any process.
    
    private let notificationCenter = NotificationCenter.default
    private let serialQueue = DispatchQueue(label: "BackgroundFetchEventProvider.serialQueue", qos: .background)
    
    // MARK: - Lifecycle
    
    init() {}
    
    // MARK: - BackgroundFetchEvents
    
    var backgroundFetchEvents: Set<BackgroundFetchEvent> {
        get {
            return serialQueue.sync {
                return userDefaults.codableValue(forKey: UserDefaultKeys.backgroundFetchEvents) ?? []
            }
        }
        set {
            serialQueue.sync {
                userDefaults.set(codable: newValue, forKey: UserDefaultKeys.backgroundFetchEvents)
            }
            
            DispatchQueue.main.async {
                self.notificationCenter.post(name: .didUpdateBackgroundFetchEvents, object: self)
            }
        }
    }
    
    func recordBackgroundFetchEvent() {
        let backgroundFetchEvent = BackgroundFetchEvent(
            occuredAt: .now,
            returnedResult: backgroundFetchResultToReturn
        )
        backgroundFetchEvents.insert(backgroundFetchEvent)
    }
    
    // MARK: - UIBackgroundFetchResult
    
    var backgroundFetchResultToReturn: UIBackgroundFetchResult {
        get {
            guard
                let rawValue = userDefaults.value(forKey: UserDefaultKeys.backgroundFetchResultToReturn) as? UInt,
                let backgroundFetchResult = UIBackgroundFetchResult(rawValue: rawValue)
                else { return .noData }
            
            return backgroundFetchResult
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: UserDefaultKeys.backgroundFetchResultToReturn)
        }
    }
}
