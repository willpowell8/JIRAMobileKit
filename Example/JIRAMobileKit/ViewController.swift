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
    var tapGestureRecognizer : UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        //JIRA.shared.setup(host: "[[JIRA_URL]]", project: "[[PROJECT_KEY]]", defaultIssueType: "[[DEFAULT_ISSUE_TYPE]]")
        JIRA.shared.setup(host: "https://tracking.keytree.net", project: "KC", defaultIssueType: "Keytree raised defect")
        JIRA.shared.globalDefaultFields = ["environment":"user: example@test.com"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func raiseBug(_ sender:Any?){
        JIRA.shared.raise()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.navBarTapped(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.removeGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func createPDF()->String{
        let fileName = "test.pdf"
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let pathForPDF = documentsDirectory.appending("/" + fileName)
        
        UIGraphicsBeginPDFContextToFile(pathForPDF, .zero, nil)
        
        let pageSize = CGRect(x:0,y:0,width:400,height:500)
        UIGraphicsBeginPDFPageWithInfo(pageSize, nil)
        let font = UIFont(name: "Helvetica", size: 12.0)
        let textRect = CGRect(x:5,y:5,width:500,height:18)
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = NSTextAlignment.left
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            
        let textColor = UIColor.black
            
        let textFontAttributes = [
                NSFontAttributeName: font!,
                NSForegroundColorAttributeName: textColor,
                NSParagraphStyleAttributeName: paragraphStyle
        ]
            
        let text = "HELLO WORLD"
        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        UIGraphicsEndPDFContext()
        return "file://"+pathForPDF
    }
    
    func navBarTapped(_ tapRecognizer: UITapGestureRecognizer){
        if tapRecognizer.state == .recognized {
            let point = tapRecognizer.location(in: self.navigationController?.navigationBar)
            if point.x > 100 && point.x < (self.navigationController?.navigationBar.frame.width)!-100 {
                JIRA.shared.raise(defaultFields: ["attachment":createPDF()])
            }
        }
        
    }
}

