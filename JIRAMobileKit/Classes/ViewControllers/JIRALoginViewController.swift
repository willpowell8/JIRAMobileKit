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
    var onLoginCompletionBlock:(()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "JIRA Login"
        hostLabel.text = JIRA.shared.host
        projectLabel.text = JIRA.shared.project
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = cancelButton
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
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        delegate?.loginDismissed()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func login(){
        guard let username = usernameField.text, !username.isEmpty else {
            let alert = UIAlertController(title: "Missing Username", message: "Username cannot be blank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                self.usernameField.becomeFirstResponder()
            })
            present(alert, animated: true, completion: nil)
            return
        }
        guard let password = passwordField.text, !password.isEmpty else {
            let alert = UIAlertController(title: "Missing Password", message: "Password cannot be blank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                self.passwordField.becomeFirstResponder()
            })
            present(alert, animated: true, completion: nil)
            return
        }
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Logging in ..."
        JIRA.shared.login(username: username, password: password) { (valid, error) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                guard valid == true else
                {
                    self.loginFailure(error)
                    return
                }
                self.dismiss(animated: true, completion: {
                    if let completion = self.onLoginCompletionBlock {
                        completion()
                    }
                    self.delegate?.loginOK()
                })
            }
        }
    }
    
    func loginFailure(_ error:String?){
        let errorStr = error ?? "Unknown error occured"
        let alert = UIAlertController(title: "Login Failure", message: errorStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { action in  })
        present(alert, animated: true, completion: nil)
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
