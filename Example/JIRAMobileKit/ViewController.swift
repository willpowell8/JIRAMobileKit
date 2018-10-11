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
        JIRA.shared.setup(host: "https://tracking.keytree.net", project: "KIT", defaultIssueType: "Keytree raised defect")
        //JIRA.shared.setup(host: "https://holtrenfrew.atlassian.net", project: "HSD")
        //JIRA.shared.setup(host: "https://burberry.atlassian.net", project: "RETAIL")
        //JIRA.shared.preAuth(username:"Holts360.User@holtrenfrew.com", password:"R3nfr3w99")
        JIRA.shared.globalDefaultFields = ["environment":"user: example@test.com"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func raiseBug(_ sender:Any?){
        JIRA.shared.raise(defaultFields: nil, withScreenshot:false)
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
            let subviews = navigationController?.navigationBar.subviews
            let point = tapRecognizer.location(in: self.navigationController?.navigationBar)
            var minX = CGFloat(0)
            var maxX = (self.navigationController?.navigationBar.frame.width)! - CGFloat(0)
            subviews?.forEach({ (view) in
                if String(describing: type(of: view)) == "_UINavigationBarContentView"{
                    let navSubViews = view.subviews
                    if navSubViews.count >= 2, String(describing: type(of: navSubViews[0])) == "_UIButtonBarStackView", String(describing: type(of: navSubViews[1])) == "_UIButtonBarStackView" {
                        
                        // left stack view
                        let leftStackMaxX = CGFloat(navSubViews[0].frame.origin.x+navSubViews[0].frame.size.width) + CGFloat(20)
                        if minX < leftStackMaxX {
                           minX = leftStackMaxX
                        }
                        
                        // right stack view
                        let rightStackMinX = navSubViews[1].frame.origin.x - CGFloat(20)
                        if maxX > rightStackMinX {
                            maxX = rightStackMinX
                        }
                        
                    }
                }
            })
            
            if point.x > minX && point.x < maxX {
                JIRA.shared.raise(defaultFields: ["attachment":createPDF()])
            }
        }
    }
}

