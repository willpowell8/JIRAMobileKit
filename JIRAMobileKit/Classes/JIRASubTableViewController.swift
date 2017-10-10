//
//  JIRASubTableViewController.swift
//  Pods
//
//  Created by Will Powell on 31/08/2017.
//
//

import UIKit
import MBProgressHUD

protocol JIRASubTableViewControllerDelegate {
    func jiraSelected(field:JIRAField?, item:Any?)
}

class JIRASubTableViewController: UITableViewController {
    
    var delegate:JIRASubTableViewControllerDelegate?
    let searchController = UISearchController(searchResultsController: nil)
    var field:JIRAField? {
        didSet{
            if let f = field {
                self.navigationItem.title = f.name
            }
            apply()
        }
    }
    var selectedFields = [DisplayClass]()
    var selectedField:DisplayClass?
    
    var elements = [DisplayClass]() {
        didSet{
            elementsFiltered = elements
        }
    }
    var elementsFiltered = [DisplayClass]() {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    func applyData(data:[AnyHashable:Any]){
        if let type = field?.schema?.type, let identifier = field?.identifier {
            if type == .array {
                if let selected = data[identifier] as? [DisplayClass] {
                    self.selectedFields = selected
                }
            }else{
                if let selected = data[identifier] as? DisplayClass {
                    self.selectedField = selected
                }
            }
        }
        self.tableView.reloadData()
    }
    
    
    func apply(){
        if let autoCompleteUrl = field?.autoCompleteUrl {
            var returnClass:JIRAEntity.Type = JIRAAllowedValue.self
            if let system = field?.schema?.system {
                switch(system){
                case .assignee:
                    returnClass = JIRAUser.self
                    break
                case .fixVersions:
                    returnClass = JIRALabel.self
                    break
                case .issuelinks:
                    returnClass = JIRAIssueSection.self
                    break
                case .labels:
                    returnClass = JIRALabel.self
                default:
                    returnClass = JIRAAllowedValue.self
                }
            }
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .indeterminate
            JIRA.shared.getChildEntities(dClass:returnClass,urlstr: autoCompleteUrl, { (error, values) in
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                }
                if let values = values as? [DisplayClass] {
                    self.elements = values
                }
            })
        }else if let allowedValues = field?.allowedValues  {
            elements = allowedValues
        }
        
        if let type = field?.schema?.type {
            if type == .array {
                tableView.allowsMultipleSelection = true
                let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
                self.navigationItem.rightBarButtonItems = [doneButton]
            }
        }
    }
    
    func done(){
        delegate?.jiraSelected(field:self.field, item: selectedFields)
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if elementsFiltered.count > 0 {
            let element = elementsFiltered[0]
            if element is ChildrenClass {
                return elementsFiltered.count
            }
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if elementsFiltered.count > 0 {
            let element = elementsFiltered[0]
            if element is ChildrenClass {
                if let currentElement = elementsFiltered[section] as? ChildrenClass {
                    if let children = currentElement.children {
                        return children.count
                    }
                    return 0
                }
            }
        }
        return elementsFiltered.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var element:DisplayClass?
        if elements.count > 0, elementsFiltered[0] is ChildrenClass  {
            if let currentElement = elementsFiltered[indexPath.section] as? ChildrenClass {
                if let children = currentElement.children {
                    element = children[indexPath.row] as! DisplayClass
                }
            }
        }else{
            element = elementsFiltered[indexPath.row]
        }
        cell.textLabel?.text = element?.label
        if let type = field?.schema?.type {
            if type == .array {
                if selectedFields.index(where: { (displayClass) -> Bool in
                    return displayClass.label == element?.label
                }) != nil {
                    cell.accessoryType = .checkmark
                }else{
                    cell.accessoryType = .none
                }
            }else{
                if let selectedElementLabel = selectedField?.label, selectedElementLabel == element?.label {
                    cell.accessoryType = .checkmark
                }else{
                    cell.accessoryType = .none
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        applySelectionToggle(tableView, didSelectRowAt: indexPath)
    }
    
    func applySelectionToggle(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if let type = field?.schema?.type {
            var elementTemp:DisplayClass?
            if elements.count > 0, elementsFiltered[0] is ChildrenClass {
                if let currentElement = elementsFiltered[indexPath.section] as? ChildrenClass {
                    if let children = currentElement.children {
                        elementTemp = children[indexPath.row] as! DisplayClass
                    }
                }
            }else{
                elementTemp = elementsFiltered[indexPath.row]
            }
            guard let element = elementTemp else {
                return
            }
            if type == .array {
                var firstIndex:Int = -1
                for i in 0..<selectedFields.count {
                    let displayClass = selectedFields[i]
                    if displayClass.label == element.label {
                        firstIndex = i
                        break;
                    }
                }
                if firstIndex > -1 {
                    selectedFields.remove(at: firstIndex)
                    tableView.cellForRow(at: indexPath)?.accessoryType = .none
                }else{
                    selectedFields.append(element)
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }
            }else{
                delegate?.jiraSelected(field:self.field, item: element)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        applySelectionToggle(tableView, didSelectRowAt: indexPath)
    }

}

extension JIRASubTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.characters.count > 0 {
            elementsFiltered = elements.filter({ (display) -> Bool in
                if let label = display.label {
                    return label.contains(text)
                }
                return false
            })
        }else{
            elementsFiltered = elements
        }
    }
}
