//
//  JIRAEntities.swift
//  Pods
//
//  Created by Will Powell on 13/08/2017.
//
//

import Foundation

enum JIRASchemaType:String {
    case string = "string"
    case array = "array"
    case number = "number"
}

enum JIRAOperations:String {
    case string = "string"
    case array = "array"
    case number = "number"
}

class JIRASchema{
    var type:JIRASchemaType?
    var system:String?
    var items:String?
}

class JIRAAllowedValues{
    var id:String?
    var desc:String? // actually description
    var archived:Bool = false
    var released:Bool = false
    var startDate:Date?
    var releaseDate:Date?
    var overdue:Bool = false
    var userStartDate:Date?
    var userReleaseDate:Date?
    var projectId:String?
    
}

class JIRAField{
    var required:Bool = false
    var schema:JIRASchema?
    var name:String?
    var hasDefaultValue:Bool = false
    var operations:[JIRAOperations]?
    var allowedValues:[JIRAAllowedValues]?
    
    func applyData(data:[AnyHashable:Any]){
        if let name = data["name"] as? String {
            self.name = name
        }
    }
}

class JIRAIssueType{
    var id:String?
    var desc:String?
    var iconUrl:String?
    var name:String?
    var subtask:Bool = false
    var fields:[JIRAField]?
    
    func applyData(data:[AnyHashable:Any]){
        if let id = data["id"] as? String {
            self.id = id
        }
        if let desc = data["description"] as? String {
            self.desc = desc
        }
        if let iconUrl = data["iconUrl"] as? String {
            self.iconUrl = iconUrl
        }
        if let name = data["name"] as? String {
            self.name = name
        }
        var fields = [JIRAField]()
        if let jiraFields = data["fields"] as? [AnyHashable:Any] {
            jiraFields.forEach({ (key,value) in
                if let v = value as? [AnyHashable:Any] {
                    let field = JIRAField()
                    field.applyData(data: v)
                    fields.append(field)
                }
            })
        }
        self.fields = fields
    }
}

class JIRAProject {
    var id:String?
    var key:String?
    var name:String?
    var avatarUrls:[String:String]?
    var issueTypes:[JIRAIssueType]?
    
    func applyData(data:[AnyHashable:Any]){
        
    }
}
