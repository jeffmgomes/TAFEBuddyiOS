//
//  StudentViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 19/3/20.
//  Copyright © 2020 Jefferson Gomes. All rights reserved.
//

import UIKit
import MBProgressHUD

class StudentViewController: UITableViewController {
    
    @IBOutlet var contentView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var studentDelegate: Student! = Student(studentId: nil, givenName: nil, lastName: nil, email: nil)
    var students: [Student]! = []
    var filteredStudents: [Student]! = []
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        studentDelegate.delegate = self
        showLoadingHUD()
        studentDelegate.getStudents()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering {
            return filteredStudents.count
        }
        return students.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentCell.identifier, for: indexPath) as! StudentCell
        var student : Student
        
        if isFiltering {
            student = filteredStudents[indexPath.row]
        } else {
            student = students[indexPath.row]
        }
        
        // Configure the cell...
        cell.studentLabel.text = "\(student.GivenName) \(student.LastName)"

        return cell
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: contentView, animated: true)
      hud.label.text = "Loading..."
    }

    private func hideLoadingHUD() {
        MBProgressHUD.hide(for: contentView, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected object to the new view controller.
        if segue.identifier == "studentQualification" {
            let controller = segue.destination as! QualificationViewController
            if let cell = sender as? StudentCell,
                let indexPath = tableView.indexPath(for: cell) {
                if isFiltering {
                    controller.student = filteredStudents[indexPath.row]
                } else {
                    controller.student = students[indexPath.row]
                }
                
            }
        }
    }
    
    func setupNavBar() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Students"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
}

extension StudentViewController: StudentProtocol {
    func itemsDownloaded(items: [Student]) {
        self.students = items
        self.tableView.reloadData()
        hideLoadingHUD()
    }
}

extension StudentViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchStudents(searchText: searchController.searchBar.text!)
    }
    
    func searchStudents(searchText: String) {
        filteredStudents = students.filter({ (student: Student) -> Bool in
            var result = false
            if student.GivenName.lowercased().contains(searchText.lowercased()) {
                result = true
            } else {
                if student.LastName.lowercased().contains(searchText.lowercased()) {
                    result = true
                }
            }
            return result
        })
        self.tableView.reloadData()
    }
}
