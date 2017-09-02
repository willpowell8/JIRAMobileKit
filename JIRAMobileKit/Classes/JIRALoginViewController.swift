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

class JIRALoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField:UITextField!
    @IBOutlet weak var passwordField:UITextField!
    
    var delegate:JIRALoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            JIRA.shared.login(username: username, password: password) { (valid) in
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    if valid == true {
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        self.loginFailure()
                    }
                }
                
            }
        }
    }
    
    func loginFailure(){
        let alert = UIAlertController(title: "Login Failure", message: "Invalid Credentials. You may need to login to jira on the web to reset any Captcha on multiple failures", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { action in
            // perhaps use action.title here
        })
    }

}
