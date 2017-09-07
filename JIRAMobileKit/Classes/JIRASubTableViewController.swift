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
    
    var field:JIRAField? {
        didSet{
            apply()
        }
    }
    var selectedFields = [DisplayClass]()
    var selectedField:DisplayClass?
    
    var elements = [DisplayClass]() {
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if elements.count > 0 {
            let element = elements[0]
            if element is ChildrenClass {
                return elements.count
            }
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if elements.count > 0 {
            let element = elements[0]
            if element is ChildrenClass {
                if let currentElement = elements[section] as? ChildrenClass {
                    if let children = currentElement.children {
                        return children.count
                    }
                    return 0
                }
            }
        }
        return elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var element:DisplayClass?
        if elements.count > 0, elements[0] is ChildrenClass  {
            if let currentElement = elements[indexPath.section] as? ChildrenClass {
                if let children = currentElement.children {
                    element = children[indexPath.row] as! DisplayClass
                }
            }
        }else{
            element = elements[indexPath.row]
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
        if let type = field?.schema?.type {
            var elementTemp:DisplayClass?
            if elements.count > 0, elements[0] is ChildrenClass {
                if let currentElement = elements[indexPath.section] as? ChildrenClass {
                    if let children = currentElement.children {
                        elementTemp = children[indexPath.row] as! DisplayClass
                    }
                }
            }else{
                elementTemp = elements[indexPath.row]
            }
            guard let element = elementTemp else {
                return
            }
            if type == .array {
                selectedFields.append(element)
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }else{
                delegate?.jiraSelected(field:self.field, item: elements[indexPath.row])
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        if let index = selectedFields.index(where: { (displayClass) -> Bool in
            return displayClass.label == element.label
        }) {
            selectedFields.remove(at: index)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
