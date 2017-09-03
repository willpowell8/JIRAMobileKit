//
//  ViewController.swift
//  JIRAMobileKit
//
//  Created by willpowell8 on 08/13/2017.
//  Copyright (c) 2017 willpowell8. All rights reserved.
//

import UIKit
import JIRAMobileKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        JIRA.shared.setup(host: "[[JIRA_URL]]", project: "[[PROJECT_KEY]]", defaultIssueType: "[[DEFAULT_ISSUE_TYPE]]")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func raiseBug(_ sender:Any?){
        JIRA.shared.raise()
    }

}

