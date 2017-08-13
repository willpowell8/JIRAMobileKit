//
//  JIRA.swift
//  Pods
//
//  Created by Will Powell on 06/02/2017.
//
//

import Foundation
import MBProgressHUD

public class JIRA {
    
    public static var shared = JIRA()

    // END POINTS
    private static let url_issue  = "rest/api/2/issue";
    private static let url_issue_attachments = "rest/api/2/issue/%@/attachments";
    private static let url_issue_createmeta = "/rest/api/2/issue/createmeta?expand=projects.issuetypes.fields"
    private static let url_myself = "/rest/api/2/myself"
    
    private var _host:String?
    public var host:String? {
        get{
            return _host
        }
    }
    
    private var _project:String?
    public var project:String? {
        get{
            return _project
        }
    }
    
    var projects:[JIRAProject]?
    
    internal static func getBundle()->Bundle{
        let podBundle =  Bundle.init(for: JIRA.self)
        let bundleURL = podBundle.url(forResource: "JIRAMobileKit" , withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
    
    public func setup(host:String, project:String){
        self._host = host
        self._project = project
    }
    
    public func raise(){
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            let newVC = JIRARaiseTableViewController() //JIRAViewController = JIRAViewController(nibName: "JIRAWindow", bundle: JIRA.getBundle())
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                
                currentController = currentController.presentedViewController
            }
            let image = UIApplication.shared.keyWindow?.capture()
            //newVC.image = image
            
            let nav = UINavigationController(rootViewController: newVC);
            nav.navigationBar.barStyle = .blackOpaque
            nav.navigationBar.tintColor = UIColor.white
            nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            nav.navigationBar.isTranslucent = false
            nav.navigationBar.isOpaque = true
            currentController.present(nav, animated: true) {
                print("Shown")
            }
        }
    }
    
    public static func raise(withImage image:UIImage){
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            let newVC: JIRAViewController = JIRAViewController(nibName: "JIRAWindow", bundle: JIRA.getBundle())
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                
                currentController = currentController.presentedViewController
            }
            newVC.image = image
            
            let nav = UINavigationController(rootViewController: newVC);
            nav.navigationBar.barStyle = .blackOpaque
            nav.navigationBar.tintColor = UIColor.white
            nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            nav.navigationBar.isTranslucent = false
            nav.navigationBar.isOpaque = true
            currentController.present(nav, animated: true) {
                print("Shown")
            }
        }
    }
    
    func generateBearerToken(username:String, password:String)->String?{
        let userPasswordString = username + ":" + password
        if let userPasswordData = userPasswordString.data(using: String.Encoding.utf8) {
            let base64EncodedCredential = userPasswordData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
            return "Basic \(base64EncodedCredential)"
        }
        return nil
    }

    func getBearerToken()->String?{
        if let username = UserDefaults.standard.string(forKey: "JIRA_USE"), let password =
            UserDefaults.standard.string(forKey: "JIRA_PWD") {
            return generateBearerToken(username: username, password: password)
        }
        return ""
    }
    
    func session()->URLSession{
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization" : getBearerToken()!]
        return URLSession(configuration: config)
    }
    
    func session(_ username:String, _ password:String)->URLSession{
        let config = URLSessionConfiguration.default
        let authString = generateBearerToken(username: username, password: password)
        config.httpAdditionalHeaders = ["Authorization" : authString]
        return URLSession(configuration: config)
    }
    
    public func login(username:String, password:String, completion: @escaping (_ completed:Bool) -> Void) {
        let url = URL(string: "\(host!)\(JIRA.url_myself)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = session(username, password).dataTask(with:request) { data, response, error in
            
            if let _ = response as? HTTPURLResponse {
                if let jsonString = String(data: data!, encoding: .utf8) {
                    print(jsonString)
                }
                do {
                    _ = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? NSDictionary
                    UserDefaults.standard.set(username, forKey: "JIRA_USE")
                    UserDefaults.standard.set(password, forKey: "JIRA_PWD")
                    UserDefaults.standard.synchronize()
                    completion(true)
                } catch {
                    print("error serializing JSON: \(error)")
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    static func environmentString()->String {
        var buildStr = "";
        var versionStr = "";
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionStr = version
        }
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildStr = version
        }
        let systemVersion = UIDevice.current.systemVersion
        return "\(UIDevice.current.model) \(systemVersion) version: \(versionStr) - build: \(buildStr)"
    }
    
    private func getParameters(issueType:String, issueSummary:String, issueDescription:String) -> [String:Any]{
        var fields:[String:Any] = [
            "project": [
                "key" : project
            ],
            "summary": issueSummary,
            "environment":JIRA.environmentString(),
            "description": issueDescription,
            "issuetype": ["name" : issueType]
        ]
        /*let customFields = CoreConfiguration.instance.getParam(param: "DATA.JIRA.fields")
        customFields?.forEach({ (key,value) in
            if let keyStr = key as? String {
                fields[keyStr] = value
            }
        })*/
        return ["fields":fields]
    }
    
    internal func createIssue(issueType:String, issueSummary:String, issueDescription:String, image:UIImage?, completion: @escaping (_ completed:Bool) -> Void){
        
        
        let url = URL(string: "\(host!)/\(JIRA.url_issue)")!
        let data = getParameters(issueType: "Bug", issueSummary: issueSummary, issueDescription: issueDescription)
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions(rawValue: 0))
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)// check for http errors
            }
            
            request.httpBody = jsonData
            let task = session().dataTask(with:request) { data, response, error in
                
                if let _ = response as? HTTPURLResponse {
                    if let jsonString = String(data: data!, encoding: .utf8) {
                        print(jsonString)
                    }
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? NSDictionary
                        let key = json?.object(forKey: "key") as? String
                        self.postImage(id: key!, issueType: issueType, issueSummary: issueSummary, issueDescription: issueDescription, image: image, completion: completion)
                    } catch {
                        print("error serializing JSON: \(error)")
                        completion(false)
                    }
                }
            }
            task.resume()
        } catch {
            print(error)
            completion(false)
        }
    }
    
    public func getIssueData(id:String, issueType:String, issueSummary:String, issueDescription:String, image:UIImage?, completion: @escaping (_ completed:Bool) -> Void){
        
        let url = URL(string: "\(host!)/rest/api/2/issue/\(id)/")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("nocheck", forHTTPHeaderField: "X-Atlassian-Token")
        
        request.httpMethod = "GET"
        let task = session().dataTask(with:request) { data, response, error in
            
            if let _ = response as? HTTPURLResponse {
                print("COMPLETED UPLOAD")
                print("WELCOME")
                if let jsonString = String(data: data!, encoding: .utf8) {
                    print(jsonString)
                }
                print("DONE")
                do {
                    let _ = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? NSDictionary
                    self.postImage(id: id, issueType: issueType, issueSummary: issueSummary, issueDescription: issueDescription, image: image, completion: completion)
                } catch {
                    print("error serializing JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    internal func postImage(id:String, issueType:String, issueSummary:String, issueDescription:String, image:UIImage?, completion: @escaping (_ completed:Bool) -> Void)
    {
        
        let url = URL(string: "\(host!)/rest/api/2/issue/\(id)/attachments")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("nocheck", forHTTPHeaderField: "X-Atlassian-Token")
        
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let image_data = UIImagePNGRepresentation(image!)
        
        
        if(image_data == nil)
        {
            return
        }
        
        
        let body = NSMutableData()
        
        let fname = "test.png"
        let mimetype = "image/png"
        
        //define the data post parameter
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        
        body.append("--\(boundary)--\r\n".data(using:String.Encoding.utf8)!)
        
        let outputData = body as Data
        request.httpBody = outputData
        
        let task = session().dataTask(with:request) { data, response, error in
            
            if let _ = response as? HTTPURLResponse {
                if let jsonString = String(data: data!, encoding: .utf8) {
                    print(jsonString)
                }
                do {
                    let _ = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? NSDictionary
                    completion(true)
                } catch {
                    print("error serializing JSON: \(error)")
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
    
    internal func createMeta(_ completion: @escaping (_ error:Bool, _ project:JIRAProject?) -> Void){
        let url = URL(string: "\(host!)\(JIRA.url_issue_createmeta)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = session().dataTask(with:request) { data, response, error in
            
            if let _ = response as? HTTPURLResponse {
                if let jsonString = String(data: data!, encoding: .utf8) {
                    print(jsonString)
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? [AnyHashable:Any]
                    var projects = [JIRAProject]()
                    if let projectsData = json?["projects"] as? [[AnyHashable:Any]]{
                        projectsData.forEach({ (projectData) in
                            let project = JIRAProject()
                            project.applyData(data: projectData)
                            projects.append(project)
                        })
                    }
                    self.projects = projects
                    let currentProject = self.projects?.filter({ (project) -> Bool in
                        return project.key == self.project
                    })
                    if currentProject?.count == 1 {
                        completion(true,currentProject?[0])
                    }else{
                        completion(false,nil)
                    }
                    
                } catch {
                    print("error serializing JSON: \(error)")
                    completion(false,nil)
                }
            }
        }
        task.resume()
    }
    
    
    public func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    public func getFullImage()->UIImage{
        let window: UIWindow! = UIApplication.shared.keyWindow
        
        return window.capture()
    }
}
