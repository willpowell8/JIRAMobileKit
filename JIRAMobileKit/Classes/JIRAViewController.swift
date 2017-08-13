//
//  JIRAViewController.swift
//  Pods
//
//  Created by Will Powell on 08/08/2017.
//
//

import Foundation
import MBProgressHUD

public class JIRAViewController: UIViewController,JIRALoginViewControllerDelegate {
    
    @IBOutlet var summaryTextField:UITextField!
    @IBOutlet var descriptionTextView:UITextView!
    @IBOutlet var imageView:UIImageView!
    
    var closeAction:Bool = false
    
    public var image:UIImage? {
        didSet{
            DispatchQueue.main.async {
                self.imageView.image = self.image
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.gray.cgColor
        
        self.navigationItem.title = "Feedback/Bug"
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItems = [cancelButton]
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItems = [saveButton]
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if closeAction == true {
            self.dismiss(animated: true, completion: nil)
        }else{
            if UserDefaults.standard.string(forKey: "JIRA_USE") == nil || UserDefaults.standard.string(forKey: "JIRA_PWD") == nil {
                let loginVC = JIRALoginViewController(nibName: "JIRALoginViewController", bundle: JIRA.getBundle())
                loginVC.delegate = self
                self.present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func save(){
        self.summaryTextField.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
        let summary = self.summaryTextField.text
        let description = self.descriptionTextView.text
        if (summary?.characters.count)! > 0 && (description?.characters.count)! > 0 {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = MBProgressHUDMode.indeterminate
            hud.label.text = "Creating..."
            JIRA.shared.createIssue(issueType: "Bug", issueSummary: summary!, issueDescription: description!, image:self.image!, completion: { (val) in
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }else{
            let alert = UIAlertController(title: "Cannot Submit", message: "Requires both title and description to be filled in", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func openImage(){
        let vc = JiraImageViewController()
        vc.delegate = self
        vc.image = image
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loginDismissed(){
        self.closeAction = true
    }
    func loginOK(){
        
    }
}

extension JIRAViewController:JiraImageViewControllerDelegate{
    func updateImage(image:UIImage){
        self.image = image
    }
}
