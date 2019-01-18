//
//  JIRA.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//

import Foundation
import MBProgressHUD

public enum JIRAAuthentication {
    case basic
    case oauth
}

public class JIRA {
    
    // Jira singleton instance
    public static var shared = JIRA()
    
    public var authenticationMethod:JIRAAuthentication = .basic
    
    public var preferredOrder = [String]() // This is how we specify the order of fields
    
    public var stringFieldsAsTextView = [String]()
    public var defaultToOnlyRequired:Bool = true

    // END POINTS
    private static let url_issue  = "rest/api/2/issue";
    private static let url_issue_attachments = "rest/api/2/issue/%@/attachments";
    private static let url_issue_createmeta = "/rest/api/2/issue/createmeta?expand=projects.issuetypes.fields"
    private static let url_myself = "/rest/api/2/myself"
    private static let url_jql_property = "/rest/api/1.0/jql/autocomplete?"
    
    internal static let MainColor = UIColor(red:32/255.0, green: 80.0/255.0, blue: 129.0/255.0,alpha:1.0)
    
    private var _host:String?
    
    // jira host eg. http://company.atlassian.net for JIRA cloud hosted
    public var host:String? {
        get{
            return _host
        }
    }
    
    private var _username:String?
    
    // jira host eg. http://company.atlassian.net for JIRA cloud hosted
    var username:String? {
        get{
            if _username != nil {
                return _username
            }
            return UserDefaults.standard.string(forKey: "JIRA_USE")
        }
        set {
            _username = newValue
            UserDefaults.standard.set(newValue, forKey: "JIRA_USE")
            UserDefaults.standard.synchronize()
        }
    }
    
    private var _password:String?
    var password:String? {
        get{
            if _password != nil {
                return _password
            }
            return UserDefaults.standard.string(forKey: "JIRA_PWD")
        }
        set {
            _password = newValue
            UserDefaults.standard.set(newValue, forKey: "JIRA_PWD")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    public func preAuth(username:String, password:String){
        _password = password
        _username = username
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
    // The fields that should be added for all tasks by default
    public var globalDefaultFields:[String:Any]?
    
    
    var projects:[JIRAProject]?
    
    internal static func getBundle()->Bundle{
        let podBundle =  Bundle.init(for: JIRA.self)
        let bundleURL = podBundle.url(forResource: "JIRAMobileKit" , withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
    
    //
    public func setup(host:String, project:String, defaultIssueType:String? = "Bug", defaultValues:[String:Any]? = nil){
        guard !host.isEmpty, URL(string:host) != nil else {
            print("JIRAKIT ERROR - Host is invalid, must be a url")
            return
        }
        
        guard project != "[[PROJECT_KEY]]" else {
            print("JIRAKIT ERROR - Project key not Set")
            return
        }
        
        var shouldReset = false
        if let originalHost = UserDefaults.standard.string(forKey: "JIRA_HOST"), let originalProject = UserDefaults.standard.string(forKey: "JIRA_PROJECT") {
            if originalHost != host || project != originalProject {
                shouldReset = true
            }
        }else{
            shouldReset = true
        }
        _host = host
        _project = project
        _defaultIssueType = defaultIssueType
        if shouldReset {
            UserDefaults.standard.set(nil, forKey: "JIRA_CREATEMETA_CACHE")
            UserDefaults.standard.set(host,forKey: "JIRA_HOST")
            UserDefaults.standard.set(project,forKey: "JIRA_PROJECT")
            UserDefaults.standard.set(nil, forKey: "JIRA_PWD")
            UserDefaults.standard.set(nil, forKey: "JIRA_USE")
            UserDefaults.standard.synchronize()
        }
    }
    
    public func doLogin(completion: @escaping ()->Void){
        guard let rootController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        let loginVC = JIRALoginViewController(nibName: "JIRALoginViewController", bundle: JIRA.getBundle())
        loginVC.onLoginCompletionBlock = completion
        /*let nav = UINavigationController(rootViewController: loginVC);
        nav.navigationBar.barStyle = .blackOpaque
        nav.navigationBar.tintColor = UIColor.white
        nav.navigationBar.barTintColor = JIRA.MainColor
        nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.isOpaque = true*/
        
        rootController.present(loginVC, animated: true, completion: nil)
    }
    
    public func doOauth(completion:@escaping () -> Void){
        /*let oauthswift = OAuth2Swift(
            consumerKey:    "E053rqqra4mXVnfhEHRYRecir5bW3K38",
            consumerSecret: "dqFbY9HrYVqAyzuFR3UGDxYUlf0zDCmVRlZFwJjYUEUJL2g-2kErIpVbKd3dRjYZ",
            authorizeUrl:   "https://auth.atlassian.com/authorize",
            accessTokenUrl: "https://auth.atlassian.com/oauth/token",
            responseType:   "code"
        )
        
        oauthswift.allowMissingStateCheck = true
        //2
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: vc, oauthSwift: oauthswift)
        
        guard let rwURL = URL(string: "jiramobilekit://oauth2Callback") else { return }
        
        //3
        oauthswift.authorize(withCallbackURL: rwURL, scope: "read:jira-user read:jira-work write:jira-work", state: "", success: {
            (credential, response, parameters) in
            print("Logged in")
        }, failure: { (error) in
            print("Failed")
        })*/
    }
    
    public func raise(defaultFields:[String:Any]? = nil, withScreenshot  screenshot:Bool = true){
        switch(self.authenticationMethod){
        case .basic:
            if JIRA.shared.username == nil || JIRA.shared.password == nil {
                doLogin {
                    self.launchCreateScreen(defaultFields: defaultFields, withScreenshot:screenshot)
                }
                return
            }
            break
        case .oauth:
            doOauth{
                self.launchCreateScreen(defaultFields: defaultFields, withScreenshot:screenshot)
            }
            return
            break
        }
        
        launchCreateScreen(defaultFields: defaultFields, withScreenshot:screenshot)
    }
    
    private func launchCreateScreen(defaultFields:[String:Any]? = nil, withScreenshot  screenshot:Bool = true){
        guard let rootController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        // Start with global fields
        var fields = self.globalDefaultFields ?? [String:Any]()
        
        // merge in default fields for current view
        if let singleDefaults = defaultFields {
            singleDefaults.forEach({ (key, value) in
                fields[key] = value
            })
        }
        
        // Add Image
        if screenshot == true, let image = UIApplication.shared.keyWindow?.capture() {
            if let attachments = fields["attachment"] {
                if var attachmentAry = attachments as? [Any] {
                    attachmentAry.insert(image, at: 0)
                    fields["attachment"] = attachmentAry
                }else{
                    fields["attachment"] = [image,attachments]
                }
            }else{
                fields["attachment"] = [image]
            }
        }
        if let environment = fields["environment"] as? String {
            fields["environment"] = environment + " " + JIRA.environmentString()
        }else{
            fields["environment"] = JIRA.environmentString()
        }
        let newVC = JIRARaiseTableViewController()
        var currentController: UIViewController! = rootController
        while( currentController.presentedViewController != nil ) {
            currentController = currentController.presentedViewController
        }
        newVC.singleInstanceDefaultFields = fields
        newVC.image = UIApplication.shared.keyWindow?.capture()
        
        let nav = UINavigationController(rootViewController: newVC);
        nav.navigationBar.barStyle = .blackOpaque
        nav.navigationBar.tintColor = UIColor.white
        nav.navigationBar.barTintColor = JIRA.MainColor
        nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.isOpaque = true
        currentController.present(nav, animated: true)
        
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
        if let username = self.username, let password =
            self.password {
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
            guard let httpURLResponse = response as? HTTPURLResponse else {
                completion(false,"Could connect to JIRA. Check your configurations.")
                return
            }
            if httpURLResponse.statusCode > 500 {
                completion(false,"Internal Server Error Occured.")
                return
            }else if httpURLResponse.statusCode > 400 {
                completion(false,"Not found or no permission to access url")
                return
            }
            do {
                _ = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? NSDictionary
                self.username = username
                self.password = password
                completion(true, nil)
            } catch {
                print("error serializing JSON: \(error)")
                completion(false,"Could not authenticate you with username \(username) and password.")
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
        
        return "\(UIDevice.current.model) \(systemVersion) version: \(versionStr) - build: \(buildStr)"
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
        guard let url = URL(string: "\(host!)/\(JIRA.url_issue)") else {
            print("JIRA KIT Error - Create url invalid")
            completion("Create url invalid", nil)
            return
        }
        let data = createDataTransferObject(issueData)
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions(rawValue: 0))
            request.httpBody = jsonData
            let task = session().dataTask(with:request) { data, response, error in
                
                guard  let _ = response as? HTTPURLResponse else {
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? NSDictionary
                    if let key = json?.object(forKey: "key") as? String {
                        if let attachments = issueData["attachment"] as? [Any] {
                            self.uploadAttachments(key: key, attachments: attachments, completion: completion)
                        }else{
                            completion(nil, key)
                        }
                        return
                    }else if let errors = json?.object(forKey: "errors") as? [String:Any] {
                        var str = [String]()
                        errors.forEach({ (key, value) in
                            if let val = value as? String {
                                str.append(val)
                            }
                        })
                        let errorMessage = str.joined(separator: "\n")
                        completion(errorMessage, nil)
                        return
                    }
                    completion("Could not complete create", nil)
                } catch {
                    print("error serializing JSON: \(error)")
                    completion("error serializing JSON: \(error)", nil)
                }
            }
            task.resume()
        } catch {
            print(error)
            completion("error serializing JSON: \(error)", nil)
        }
    }
    
    
    internal func uploadAttachments(key:String, attachments:[Any], completion: @escaping (_ error:String?,_ key:String?) -> Void){
        var datas = [(name:String, data:Data, mimeType:String)]()
        attachments.forEach { (attachment) in
            if let attachmentPath = attachment as? String, let attachmentURL:URL = URL(string:attachmentPath) {
                if let data = try? Data(contentsOf:attachmentURL) {
                    let mimeType = attachmentURL.absoluteString.mimeType()
                    let fileName = attachmentURL.lastPathComponent
                    datas.append((name: fileName, data: data, mimeType: mimeType))
                }
            }else if let attachmentURL = attachment as? URL {
                if let data = try? Data(contentsOf:attachmentURL) {
                    let mimeType = attachmentURL.absoluteString.mimeType()
                    let fileName = attachmentURL.lastPathComponent
                    datas.append((name: fileName, data: data, mimeType: mimeType))
                }
            }else if let attachmentImage = attachment as? UIImage{
                if let data = attachmentImage.pngData() {
                    datas.append((name: "Screenshot.png", data: data, mimeType: "image/png"))
                }
            }
        }
        uploadDataAttachments(key:key, attachments: datas, count:0, completion: completion)
    }
    
    internal func uploadDataAttachments(key:String, attachments:[(name:String, data:Data, mimeType:String)], count:Int, completion: @escaping (_ error:String?,_ key:String?) -> Void){
        if count >= attachments.count {
            completion(nil, key)
        }else{
            let attachment = attachments[count]
            postAttachment(key: key, data: attachment, completion: { (error, keyStr) in
                self.uploadDataAttachments(key: key, attachments: attachments, count: (count + 1), completion: completion)
            })
        }
    }
    
    internal func postAttachment(key:String, data:(name:String, data:Data, mimeType:String), completion: @escaping (_ error:String?,_ key:String?) -> Void)
    {
        let url = URL(string: "\(host!)/rest/api/2/issue/\(key)/attachments")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("nocheck", forHTTPHeaderField: "X-Atlassian-Token")
        
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let attachmentData = data.data
        
        let body = NSMutableData()
        
        let fname = data.name
        let mimetype = data.mimeType
        
        //define the data post parameter
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(attachmentData)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using:String.Encoding.utf8)!)
        
        let outputData = body as Data
        request.httpBody = outputData
        
        let task = session().dataTask(with:request) { data, response, error in
            
            if let _ = response as? HTTPURLResponse {
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
        if let cachedData = UserDefaults.standard.data(forKey: "JIRA_CREATEMETA_CACHE") {
            processCreateMetaData(cachedData, completion: { [weak self] (err, project) in
                guard err == false else {
                    self?.continueCreateMeta(completion)
                    return
                }
                self?.continueCreateMeta(completion)
            })
            return
        }
        continueCreateMeta(completion)
    }
    
    internal func continueCreateMeta(_ completion: @escaping (_ error:Bool, _ project:JIRAProject?) -> Void){
        let url = URL(string: "\(host!)\(JIRA.url_issue_createmeta)&projectKeys=\(self.project!)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = session().dataTask(with:request) { data, response, error in
            if let _ = response as? HTTPURLResponse {
                UserDefaults.standard.set(data!, forKey: "JIRA_CREATEMETA_CACHE")
                UserDefaults.standard.synchronize()
                self.processCreateMetaData(data, completion: completion)
            }
        }
        task.resume()
    }
    
    internal func jqlQuery(field:JIRAField, term:String,_ completion: @escaping (_ error:Bool, _ options:[JIRAJQLValue]?) -> Void){
        guard let fieldName = field.name else{
            return;
        }
        
       guard let fieldNameEscaped = fieldName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let termEscaped = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string:"\(host!)\(JIRA.url_jql_property)fieldName=\(fieldNameEscaped)&fieldValue=\(termEscaped)") else{
            return
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = session().dataTask(with:request) { data, response, error in
            if let _ = response as? HTTPURLResponse {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? [AnyHashable:Any]
                    if let items = json?["results"] as? [[String:String]] {
                        let options = items.compactMap({ (item) -> JIRAJQLValue? in
                            let v = JIRAJQLValue()
                            v.applyData(data: item)
                            return v
                        })
                        return completion(false, options)
                    }
                    return completion(true, nil)
                } catch {
                    print("error serializing JSON: \(error)")
                    DispatchQueue.main.async {
                        completion(true,nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func processCreateMetaData(_ data:Data?, completion: @escaping (_ error:Bool, _ project:JIRAProject?) -> Void){
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
                    completion(false,currentProject?[0])
                }
            }else{
                // todo when no project is found error
                DispatchQueue.main.async {
                    completion(true,nil)
                }
            }
            
        } catch {
            print("error serializing JSON: \(error)")
            DispatchQueue.main.async {
                completion(true,nil)
            }
        }
    }
    
    internal func getChildEntities(dClass: JIRAEntity.Type,urlstr:String, _ completion: @escaping (_ error:Bool, _ values:[JIRAEntity]?) -> Void){
        guard var urlComponents = URLComponents(string: urlstr) else {
            completion(true, nil)
            return
        }
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
        guard let url = urlComponents.url else {
            completion(true, nil)
            return
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = session().dataTask(with:request) { data, response, error in
            if let _ = response as? HTTPURLResponse {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    var values = [JIRAEntity]()
                    if let jsonAry = json as? [[AnyHashable:Any]] {
                        values = jsonAry.compactMap({ (element) -> JIRAEntity? in
                            let val = dClass.init()
                            if let valDisplayClass = val as? DisplayClass {
                                valDisplayClass.applyData(data: element)
                            }
                            return val
                        })
                    }else if let jsonData = json as? [AnyHashable:Any] {
                        if let jsonAry = jsonData["suggestions"] as? [[AnyHashable:Any]] {
                            values = jsonAry.compactMap({ (element) -> JIRAEntity? in
                                let val = dClass.init()
                                if let valDisplayClass = val as? DisplayClass {
                                    valDisplayClass.applyData(data: element)
                                }
                                return val
                            })
                        }else if let jsonAry = jsonData["sections"] as? [[AnyHashable:Any]] {
                            values = jsonAry.compactMap({ (element) -> JIRAEntity? in
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
