import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool
    {
        // Required for Background App Refresh to work.
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        let backgroundFetchEventProvider = Providers.backgroundFetchEventProvider
        backgroundFetchEventProvider.recordBackgroundFetchEvent()
        completionHandler(backgroundFetchEventProvider.backgroundFetchResultToReturn)
    }
}

