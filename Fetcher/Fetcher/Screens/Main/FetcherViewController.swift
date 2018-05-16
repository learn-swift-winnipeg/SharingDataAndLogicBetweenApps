import UIKit

class FetcherViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backgroundFetchResultBlurContainer: UIVisualEffectView!
    @IBOutlet var backgroundFetchResultSegmentedControl: UISegmentedControl!
    
    // MARK: - Stored Properties
    
    private let notificationCenter = NotificationCenter.default
    private let backgroundFetchEventProvider = Providers.backgroundFetchEventProvider
    private var backgroundFetchEvents: [BackgroundFetchEvent] = []
    private let dateFormatter = DateFormatter(dateStyle: .short, timeStyle: .long)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        registerForSystemNotifications()
        fetchBackgroundFetchEvents(reloadTable: false)
        updateBackgroundFetchResultSegementedControl()
    }
    
    deinit {
        deregisterForNotifications()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.dataSource = self
    }
    
    // MARK: - System Notifications
    
    private func registerForSystemNotifications() {
        notificationCenter.addObserver(
            forName: .didUpdateBackgroundFetchEvents,
            object: backgroundFetchEventProvider,
            queue: .main,
            using: { [weak self] _ in self?.fetchBackgroundFetchEvents(reloadTable: true) }
        )
    }
    
    private func deregisterForNotifications() {
        notificationCenter.removeObserver(self)
    }
    
    // MARK: - Fetching
    
    private func fetchBackgroundFetchEvents(reloadTable: Bool) {
        backgroundFetchEvents = backgroundFetchEventProvider.backgroundFetchEvents
            .sorted(by: { $0.occuredAt > $1.occuredAt })
        
        if reloadTable { tableView.reloadData() }
    }
    
    // MARK: - Update
    
    private func updateBackgroundFetchResultSegementedControl() {
        let selectedSegmentIndex: Int
        
        switch backgroundFetchEventProvider.backgroundFetchResultToReturn {
        case .noData: selectedSegmentIndex = 0
        case .newData: selectedSegmentIndex = 1
        case .failed: selectedSegmentIndex = 2
        }
        
        backgroundFetchResultSegmentedControl.selectedSegmentIndex = selectedSegmentIndex
    }
    
    // MARK: - Actions
    
    @IBAction func reloadTapped(_ sender: Any) {
        fetchBackgroundFetchEvents(reloadTable: true)
    }
    
    @IBAction func backgroundFetchResultValueChanged(_ sender: Any) {
        let backgroundFetchResult: UIBackgroundFetchResult
        
        switch backgroundFetchResultSegmentedControl.selectedSegmentIndex {
        case 0: backgroundFetchResult = .noData
        case 1: backgroundFetchResult = .newData
        case 2: backgroundFetchResult = .failed
        default:
            fatalError("backgroundFetchResultValueChanged to unknown value for index: \(backgroundFetchResultSegmentedControl.selectedSegmentIndex)")
        }
        
        backgroundFetchEventProvider.backgroundFetchResultToReturn = backgroundFetchResult
    }
}

// MARK: - UITableViewDataSource

extension FetcherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backgroundFetchEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let backgroundFetchEvent = backgroundFetchEvents[indexPath.row]
        cell.textLabel?.text = dateFormatter.string(from: backgroundFetchEvent.occuredAt)
        cell.detailTextLabel?.text = backgroundFetchEvent.returnedResult.description
        
        return cell
    }
}

