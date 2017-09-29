//
//  JIRA.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//

import Foundation
import MBProgressHUD

public class JIRA {
    
    // Jira singleton instance
    public static var shared = JIRA()

    // END POINTS
    private static let url_issue  = "rest/api/2/issue";
    private static let url_issue_attachments = "rest/api/2/issue/%@/attachments";
    private static let url_issue_createmeta = "/rest/api/2/issue/createmeta?expand=projects.issuetypes.fields"
    private static let url_myself = "/rest/api/2/myself"
    
    internal static let MainColor = UIColor(red:32/255.0, green: 80.0/255.0, blue: 129.0/255.0,alpha:1.0)
    
    private var _host:String?
    
    // jira host eg. http://company.atlassian.net for JIRA cloud hosted
    public var host:String? {
        get{
            return _host
        }
    }
    
    private var _project:String?
    
    // this is the core project identifier for the project within JIRA
    public var project:String? {
        get{
            return _project
        }
    }
    
    private var _defaultIssueType:String?
    
    // the issue type that you would like the application to use as the default starting case
    public var defaultIssueType:String? {
        get{
            return _defaultIssueType
        }
    }
    
    public static var defaultFields:[String:Any]?
    
    
    var projects:[JIRAProject]?
    
    internal static func getBundle()->Bundle{
        let podBundle =  Bundle.init(for: JIRA.self)
        let bundleURL = podBundle.url(forResource: "JIRAMobileKit" , withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
    
    //
    public func setup(host:String, project:String, defaultIssueType:String? = "Bug", defaultValues:[String:Any]? = nil){
        self._host = host
        self._project = project
        self._defaultIssueType = defaultIssueType
    }
    
    public func raise(){
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            let newVC = JIRARaiseTableViewController()
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            
            newVC.image = UIApplication.shared.keyWindow?.capture()
            
            let nav = UINavigationController(rootViewController: newVC);
            nav.navigationBar.barStyle = .blackOpaque
            nav.navigationBar.tintColor = UIColor.white
            nav.navigationBar.barTintColor = JIRA.MainColor
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
        if let authString = generateBearerToken(username: username, password: password) {
            config.httpAdditionalHeaders = ["Authorization" : authString]
        }
        return URLSession(configuration: config)
    }
    
    public func login(username:String, password:String, completion: @escaping (_ completed:Bool, _ error:String?) -> Void) {
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
                    completion(true, nil)
                } catch {
                    print("error serializing JSON: \(error)")
                    completion(false,"Could not authenticate you. You may need to login on the web to reset captcha before trying again.")
                }
            }else{
                completion(false,"Could connect to JIRA. Check your configurations.")
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
        /*var output = ""
        Bundle.allFrameworks.forEach { (bundle) in
            if let bundleIdentifier = bundle.bundleIdentifier, bundleIdentifier.contains("com.apple") == false{
                var record = bundleIdentifier
                if let version = bundle.infoDictionary!["CFBundleShortVersionString"] as? String {
                    record += " - \(version)"
                }
                output += record+"\n"
            }
        }*/
        
        var environmentStr = "\(UIDevice.current.model) \(systemVersion) version: \(versionStr) - build: \(buildStr)"
        if let defaults = defaultFields, let str = defaults["environment"] as? String {
            environmentStr += str
        }
        
        return environmentStr
    }
    
    private func createDataTransferObject(_ issueData:[AnyHashable:Any]) -> [String:Any]{
        var data = [String:Any]()
        issueData.forEach { (key,value) in
            if let key = key as? String {
                if value is String {
                    data[key] = value
                }else if let jiraEntity = value as? JIRAEntity {
                    data[key] = jiraEntity.export()
                }else if let jiraEntityAry = value as? [JIRAEntity] {
                    let entities = jiraEntityAry.map({ (entity) -> Any? in
                        return entity.export()
                    })
                    data[key] = entities
                }
            }
        }
        
        return ["fields":data]
    }
    
    internal func create(issueData:[AnyHashable:Any], completion: @escaping (_ error:String?,_ key:String?) -> Void){
        let url = URL(string: "\(host!)/\(JIRA.url_issue)")!
        let data = createDataTransferObject(issueData)
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
                        if let key = json?.object(forKey: "key") as? String {
                            if let image = issueData["attachment"] as? UIImage {
                                self.postImage(key: key, image: image, completion: completion)
                            }else{
                                completion(nil, key)
                            }
                        }else if let errors = json?.object(forKey: "errors") as? [String:Any] {
                            var str = [String]()
                            errors.forEach({ (key, value) in
                                if let val = value as? String {
                                    str.append(val)
                                }
                            })
                            let errorMessage = str.joined(separator: "\n")
                            completion(errorMessage, nil)
                        }
                    } catch {
                        print("error serializing JSON: \(error)")
                        completion("error serializing JSON: \(error)", nil)
                    }
                }
            }
            task.resume()
        } catch {
            print(error)
            completion("error serializing JSON: \(error)", nil)
        }
    }
    
    internal func postImage(key:String, image:UIImage?, completion: @escaping (_ error:String?,_ key:String?) -> Void)
    {
        let url = URL(string: "\(host!)/rest/api/2/issue/\(key)/attachments")!
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
        
        let fname = "screenshot.png"
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
                    completion(nil, key)
                } catch {
                    print("error serializing JSON: \(error)")
                    completion("error serializing JSON: \(error)", nil)
                }
            }else{
                completion("error connecting to JIRA no attachment uploaded", nil)
            }
        }
        
        task.resume()
    }
    
    internal func createMeta(_ completion: @escaping (_ error:Bool, _ project:JIRAProject?) -> Void){
        let url = URL(string: "\(host!)\(JIRA.url_issue_createmeta)&projectKeys=\(self.project!)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = session().dataTask(with:request) { data, response, error in
            if let _ = response as? HTTPURLResponse {
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
                        DispatchQueue.main.async {
                             completion(true,currentProject?[0])
                        }
                       
                    }else{
                        DispatchQueue.main.async {
                            completion(false,nil)
                        }
                    }
                    
                } catch {
                    print("error serializing JSON: \(error)")
                    DispatchQueue.main.async {
                        completion(false,nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    internal func getChildEntities(dClass: JIRAEntity.Type,urlstr:String, _ completion: @escaping (_ error:Bool, _ values:[JIRAEntity]?) -> Void){
        guard var urlComponents = URLComponents(string: urlstr) else { return }
        var parameters = urlComponents.queryItems?.filter({ (queryItem) -> Bool in
            return queryItem.value != "null"
        })
        let params = parameters?.map({ (queryItem) -> URLQueryItem in
            if queryItem.name == "currentProjectId" {
                return URLQueryItem(name: "currentProjectId", value: project)
            }
            return queryItem
        })
        if let params2 = params{
            parameters = params2
        }
        parameters?.append(URLQueryItem(name: "project", value: project))
        urlComponents.queryItems = parameters
        let url = urlComponents.url!
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
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    var values = [JIRAEntity]()
                    if let jsonAry = json as? [[AnyHashable:Any]] {
                        values = jsonAry.flatMap({ (element) -> JIRAEntity? in
                            let val = dClass.init()
                            if let valDisplayClass = val as? DisplayClass {
                                valDisplayClass.applyData(data: element)
                            }
                            return val
                        })
                    }else if let jsonData = json as? [AnyHashable:Any] {
                        if let jsonAry = jsonData["suggestions"] as? [[AnyHashable:Any]] {
                            values = jsonAry.flatMap({ (element) -> JIRAEntity? in
                                let val = dClass.init()
                                if let valDisplayClass = val as? DisplayClass {
                                    valDisplayClass.applyData(data: element)
                                }
                                return val
                            })
                        }else if let jsonAry = jsonData["sections"] as? [[AnyHashable:Any]] {
                            values = jsonAry.flatMap({ (element) -> JIRAEntity? in
                                let val = dClass.init()
                                if let valDisplayClass = val as? DisplayClass {
                                    valDisplayClass.applyData(data: element)
                                }
                                return val
                            })
                        }
                    }
                    
                    completion(true,values)
                    
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
