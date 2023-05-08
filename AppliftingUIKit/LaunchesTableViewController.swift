import UIKit
import SwiftUI

class LaunchesTableViewController: UITableViewController, UISearchResultsUpdating {
    enum SortOption: Int {
        case aToZ, earliest, latest
    }
   
    let searchController = UISearchController(searchResultsController: nil)
    let defaults = UserDefaults.standard
    private var launches: [Launch] = []
    private var searchedData: [Launch] = []
    private var currentSort: SortOption = .aToZ {
        didSet {
            sortLaunches()
            defaults.set(currentSort.rawValue, forKey: "SortOption")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await fetchData()
        }
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort by", style: .plain, target: self, action: #selector(presentActionSheet))
    }
    
    @MainActor
    func fetchData() async {
        do {
            self.launches = try await Network.getLaunches()
            if let defaultSorting = defaults.object(forKey: "SortOption") as! Int? {
                currentSort = SortOption(rawValue: defaultSorting) ?? self.currentSort
            }
            updateSearchResults(for: searchController)
        } catch {
            showAlert()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            searchedData = launches
            tableView.reloadData()
            return
        }
        if searchText.isEmpty {
            searchedData = launches
        } else {
            searchedData = launches.filter { launch in
                launch.name.contains(searchText)
            }
        }
        tableView.reloadData()
    }
    
    func sortLaunches() {
        switch currentSort {
        case .aToZ:
            launches = launches.sorted(by: { $0.name < $1.name })
        case .earliest:
            launches = launches.sorted(by: { $0.dateUnix < $1.dateUnix })
        case .latest:
            launches = launches.sorted(by: { $0.dateUnix > $1.dateUnix })
        }
        updateSearchResults(for: searchController)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Launches cannot be loaded. Please, check your internet connection and click refresh.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Refresh", style: .default, handler: { _ in
            Task { await self.fetchData() }
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }

    @objc func presentActionSheet() {
        let actionSheet = UIAlertController(title: "Sort by:", message: nil, preferredStyle: .actionSheet)
        let option1 = UIAlertAction(title: "Name from A to Z", style: .default) { _ in
            self.currentSort = .aToZ
        }
        let option2 = UIAlertAction(title: "Earliest", style: .default) { _ in
            self.currentSort = .earliest
        }
        let option3 = UIAlertAction(title: "Latest", style: .default) { _ in
            self.currentSort = .latest
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(option1)
        actionSheet.addAction(option2)
        actionSheet.addAction(option3)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LaunchCell", for: indexPath)
        let launch = searchedData[indexPath.row]
        cell.textLabel?.text = launch.name
        cell.detailTextLabel?.text = launch.dateUnix.formatted(date: .abbreviated, time: .omitted)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let launch = searchedData[indexPath.row]
        let controller = UIHostingController(rootView: DetailView(launch: launch))
        navigationController?.pushViewController(controller, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
