import UIKit
import SwiftUI

class LaunchesTableViewController: UITableViewController, UISearchResultsUpdating {
    enum SortOption: Int {
        case aToZ, earliest, latest
    }
    
    private var launches: [Launch] = []
    private var searchedData: [Launch] = []
    private var currentSort: SortOption = .aToZ {
        didSet {
            sortLaunches()
            updateSearchResults(for: searchController)
        }
    }
    let searchController = UISearchController(searchResultsController: nil)
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                self.launches = try await Network.getLaunches()
                updateSearchResults(for: searchController)
            } catch {
                print("Error \(error)")
            }
        }
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort by", style: .plain, target: self, action: #selector(presentActionSheet))
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

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
