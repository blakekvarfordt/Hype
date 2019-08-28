//
//  HypeTableViewController.swift
//  Hype
//
//  Created by Blake kvarfordt on 8/26/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import UIKit

class HypeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        configureRefreshControl()
    }

    func configureRefreshControl () {
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action:
            #selector(handleRefreshControl),
                                                  for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        loadData()

        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    func loadData() {
        HypeController.shared.fetchDemHypes { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    func addAlert(hype: Hype?) {
        // create alert controller
        let alertController = UIAlertController(title: "Get Hype", message: "Hype is up sir!", preferredStyle: .alert)
        // add text field to controller
        alertController.addTextField { (textField) in
            textField.placeholder = "Yeah Buddy"
        }
        // create save action button for controller
        let hypeAction = UIAlertAction(title: "Add Hype", style: .default) { (_) in
            // get text from text field
            guard let text = alertController.textFields?.first?.text else { return }
            // actually add hype if there is text
            if text != "" && hype == nil {
                // This is a closure so it will be on a background thread
                HypeController.shared.saveHype(with: text, completion: { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            } else {
                guard let hype = hype else { return }
                HypeController.shared.update(hype: hype, with: text, completion: { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
        // set up cancelation action button on alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        // add actions to controller
        alertController.addAction(hypeAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return HypeController.shared.hypes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        let hype = HypeController.shared.hypes[indexPath.row]
        
        cell.textLabel?.text = hype.text
        let date = DateHelper.shared.mediumStringFor(date: hype.timestamp)
        cell.detailTextLabel?.text = date

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hype = HypeController.shared.hypes[indexPath.row]
        addAlert(hype: hype)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let hype = HypeController.shared.hypes[indexPath.row]
            HypeController.shared.remove(hype: hype) { (success) in
                if success == true {
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addAlert(hype: nil)
    }

}
