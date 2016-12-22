//
//  ASHMasterViewController.swift
//  C-41
//
//  Created by Nicholas Sakaimbo on 12/22/16.
//  Copyright © 2016 Ash Furrow. All rights reserved.
//

import UIKit

class ASHMasterViewController: UITableViewController {
    
    var viewModel: ASHMasterViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        _ = viewModel?.updatedContentSignal.subscribeNext { [weak self] _ in
            self?.tableView?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.isActive = true
    }
    
    //MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfItemsInSection(section) ?? 0
    }
    
    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = viewModel?.titleAtIndexPath(indexPath)
        cell.detailTextLabel?.text = viewModel?.subtitleAtIndexPath(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            viewModel?.deleteObjectAtIndexPath(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.titleForSection(section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing {
            
            if let storyboard = storyboard {
                
                let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: ASHEditRecipeViewController.self)) as! ASHEditRecipeViewController
                viewController.viewModel = viewModel?.editViewModelForIndexPath(indexPath)
                
                let navigationController = UINavigationController(rootViewController: viewController)
                
                present(navigationController, animated: true, completion: nil)
            }
        } else {
            // Storyboard segue will handle the navigation event
        }
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifer = segue.identifier else { return }
        
        switch identifer {
            case "showDetail":
                
                if let indexPath = tableView.indexPathForSelectedRow,
                    let viewController = segue.destination as? ASHDetailViewController {
                    
                    viewController.viewModel = viewModel?.detailViewModelForIndexPath(indexPath)
                }
            
            case "editRecipe":
            
                if let editNavigationController = segue.destination as? UINavigationController,
                    let viewController = editNavigationController.topViewController as? ASHEditRecipeViewController {
                    
                    viewController.viewModel = viewModel?.editViewModelForNewRecipe()
            }
 
        default:
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return isEditing == false
    }
}
