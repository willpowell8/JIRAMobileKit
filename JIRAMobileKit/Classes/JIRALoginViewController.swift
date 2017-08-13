//
//  JIRALoginViewController.swift
//  Pods
//
//  Created by Will Powell on 08/08/2017.
//
//

import UIKit

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
            JIRA.shared.login(username: username, password: password) { (valid) in
                if valid == true {
                    print("VALID")
                    self.dismiss(animated: true, completion: nil)
                }else{
                    print("NOT VALID")
                }
            }
        }
    }

}
