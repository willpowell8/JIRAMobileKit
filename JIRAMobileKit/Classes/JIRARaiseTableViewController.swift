//
//  JIRARaiseTableViewController.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//

import UIKit
import MBProgressHUD
import QuickLook


class JIRARaiseTableViewController: UITableViewController {
    
    let quickLookController = QLPreviewController()
    var quickLookSelected = [QLPreviewItem]()

    var closeAction:Bool = false
    var project:JIRAProject?
    var issueType:JIRAIssueType? {
        didSet{
            generateInitialData()
            createCells()
        }
    }
    
    var hasLoaded = false
    var cells = [JIRACell]()
    var selectedCell:JIRACell?
    
    var singleInstanceDefaultFields:[String:Any]?
    
    var image:UIImage?
    var data = [String:Any]() // working ticket data
    
    func generateInitialData(){
        var newData = [String:Any]()
        issueType?.fields?.forEach({ (field) in
            if let type = field.schema?.type {
                switch(type){
                default:
                    if let identifier = field.identifier, let instanceData = singleInstanceDefaultFields?[identifier] {
                        newData[identifier] = instanceData
                    }else if let system = field.schema?.system, system == .attachment {
                        newData["attachment"] = image
                    }else{
                        if let allowedValues = field.allowedValues, allowedValues.count == 1, let identifier =  field.identifier {
                            newData[identifier] = allowedValues[0]
                        }
                    }
                }
            }
        })
        data = newData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "JIRA"
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItems = [cancelButton]
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItems = [saveButton]
        if UserDefaults.standard.string(forKey: "JIRA_USE") == nil || UserDefaults.standard.string(forKey: "JIRA_PWD") == nil {
            let loginVC = JIRALoginViewController(nibName: "JIRALoginViewController", bundle: JIRA.getBundle())
            loginVC.delegate = self
            self.present(loginVC, animated: true, completion: nil)
        }else{
            self.load()
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if closeAction == true {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func load(){
        guard hasLoaded == false else {
            return
        }
        hasLoaded = true
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Loading ..."
        JIRA.shared.createMeta({ (error, project) in
            self.project = project
            if let issueTypes = project?.issueTypes {
                let issueType = issueTypes.first(where: { (issue) -> Bool in
                    return issue.name?.lowercased() == JIRA.shared.defaultIssueType?.lowercased()
                })
                self.issueType = issueType
            }else{
                self.issueType = project?.issueTypes?[0]
            }
            hud.hide(animated: true)
            self.tableView.reloadData()
        })
    }
    
    func deselectCells(){
        self.cells.forEach { (cell) in
            if cell != selectedCell {
                cell.deselect()
            }
        }
    }
    
    func createCells(){
        issueType?.fields?.forEach({ (field) in
            let validField = (field.operations?.contains(JIRAOperations.set))! || field.identifier! == "attachment"
            if validField {
                if let type = field.schema?.type {
                    var cell:JIRACell?
                    switch(type){
                    case .string:
                        if let allowedValues = field.allowedValues, allowedValues.count > 0 {
                            cell = JIRAOptionCell(style: .value1, reuseIdentifier: "cell")
                        }else{
                            cell = JIRATextFieldCell(style: .value1, reuseIdentifier: "cell")
                        }
                    case .array:
                        if let system = field.schema?.system, system == .attachment {
                            let imageCell = JIRAImageCell(style: .value1, reuseIdentifier: "cell")
                            imageCell.delegateSelection = self
                            cell = imageCell
                        }else{
                            cell = JIRAOptionCell(style: .value1, reuseIdentifier: "cell")
                        }
                    default:
                        cell = JIRAOptionCell(style: .value1, reuseIdentifier: "cell")
                    }
                    if let cellV = cell {
                        cellV.delegate = self
                        cellV.field = field
                        cellV.start(field: field, data: self.data)
                        self.cells.append(cellV)
                    }
                }
            }
        })
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func save(){
        // todo validate before save
        
        cells.forEach { (cell) in
            cell.deselect()
        }
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Creating..."
        JIRA.shared.create(issueData: self.data, completion: { (error, key) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    let alert = UIAlertController(title: "Created", message: key, preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cells.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cells[indexPath.row]
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.cells[indexPath.row]
        self.selectedCell = cell
        self.deselectCells()
        let field = cell.field
        if let type = field?.schema?.type {
            if type == .string {
                if let allowedValues = field?.allowedValues, allowedValues.count > 0 {
                    let table = JIRASubTableViewController()
                    table.field = field
                    table.delegate = self
                    table.applyData(data: data)
                    self.navigationController?.pushViewController(table, animated: true)
                    return;
                }
                return;
            }
            if type == .array, let system = field?.schema?.system, system == .attachment {
                
                if let identifier = field?.identifier, let attachments = data[identifier] as? [Any] {
                    let layout = UICollectionViewFlowLayout()
                    layout.scrollDirection = .vertical
                    layout.itemSize = CGSize(width: 160, height: 200)
                    layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                    let attachmentView = JIRAAttachmentsCollectionViewController(collectionViewLayout: layout)
                    attachmentView.attachments = attachments
                    attachmentView.delegate = self
                    attachmentView.field = field
                    self.navigationController?.pushViewController(attachmentView, animated: true)
                    return;
                }
                
            }
            let table = JIRASubTableViewController()
            table.field = field
            table.delegate = self
            table.applyData(data: data)
            self.navigationController?.pushViewController(table, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.cells[indexPath.row]
        return cell.height()
    }
    
}

extension JIRARaiseTableViewController:QLPreviewControllerDelegate, QLPreviewControllerDataSource{
    // MARK: - Preview controller datasource  functions
    
    func numberOfPreviewItems(in: QLPreviewController) -> Int {
        return quickLookSelected.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return quickLookSelected[index]
    }
    
    // MARK: - Preview controller delegate functions
    
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
       
    }
    
    func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
        return true
    }
}

extension JIRARaiseTableViewController:JIRALoginViewControllerDelegate{
    func loginDismissed(){
        self.closeAction = true
    }
    
    func loginOK() {
        
    }
}

extension JIRARaiseTableViewController:JIRAImageCellDelegate{
    func jiraImageCellSelected(cell:JIRACell, any: Any, index: Int) {
        self.selectedCell = cell
        if let image = any as? UIImage {
            let jiraImageVC = JiraImageViewController()
            jiraImageVC.image = image
            jiraImageVC.attachmentID = index
            jiraImageVC.delegate = self
            self.navigationController?.pushViewController(jiraImageVC, animated: true)
        }else if let urlString = any as? String, let url = URL(string:urlString){
            let filePreview = url as QLPreviewItem
            quickLookSelected = [filePreview]
            quickLookController.delegate = self
            quickLookController.dataSource = self
            self.present(quickLookController, animated: true, completion: nil)
        }else if let url =  any as? URL{
            let filePreview = url as QLPreviewItem
            quickLookSelected = [filePreview]
            quickLookController.delegate = self
            quickLookController.dataSource = self
            self.present(quickLookController, animated: true, completion: nil)
        }
    }
}

extension JIRARaiseTableViewController:JIRASubTableViewControllerDelegate {
    func jiraSelected(field:JIRAField?, item: Any?) {
        guard let field = field, let identifier = field.identifier else {
            return
        }
        self.data[identifier] = item
        self.selectedCell?.applyData(data: self.data)
    }
}

extension JIRARaiseTableViewController:JiraImageViewControllerDelegate {
    func updateImage(image: UIImage, attachmentID:Int) {
        if let selectedCell = self.selectedCell {
            guard let field = selectedCell.field, let identifier = field.identifier else {
                return
            }
            if var ary = self.data[identifier] as? [Any] {
                ary[attachmentID] = image
                self.data[identifier] = ary
            }
            
            self.selectedCell?.applyData(data: self.data)
        }
    }
}
