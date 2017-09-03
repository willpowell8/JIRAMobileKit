//
//  JIRALoginViewController.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//

import UIKit
import MBProgressHUD

protocol JIRALoginViewControllerDelegate {
    func loginDismissed()
    func loginOK()
}

class JIRALoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var usernameField:UITextField!
    @IBOutlet weak var passwordField:UITextField!
    
    @IBOutlet weak var hostLabel:UILabel!
    @IBOutlet weak var projectLabel:UILabel!
    
    var delegate:JIRALoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        hostLabel.text = JIRA.shared.host
        projectLabel.text = JIRA.shared.project
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func close(){
        self.delegate?.loginDismissed()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func login(){
        if let username = self.usernameField.text, let password = self.passwordField.text {
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .indeterminate
            hud.label.text = "Logging in ..."
            JIRA.shared.login(username: username, password: password) { (valid, error) in
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    if valid == true {
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        self.loginFailure(error)
                    }
                }
                
            }
        }
    }
    
    func loginFailure(_ error:String?){
        let errorStr = error ?? "Unknown error occured"
        let alert = UIAlertController(title: "Login Failure", message: errorStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { action in
            // perhaps use action.title here
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        }else if textField == passwordField {
            login()
        }
        return true
    }

}
