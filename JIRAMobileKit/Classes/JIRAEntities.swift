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
    func applyData(data:[AnyHashable:Any]){
        if let typeStr = data["type"] as? String, let type = JIRASchemaType(rawValue:typeStr)  {
            self.type = type
        }
        if let system = data["system"] as? String {
            self.system = system
        }
        if let items = data["items"] as? String {
            self.items = items
        }
    }
}

class JIRAAllowedValue{
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
    func applyData(data:[AnyHashable:Any]){
        if let id = data["id"] as? String {
            self.id = id
        }
        if let desc = data["description"] as? String {
            self.desc = desc
        }
    }
}

class JIRAField{
    var required:Bool = false
    var schema:JIRASchema?
    var name:String?
    var hasDefaultValue:Bool = false
    var operations:[JIRAOperations]?
    var allowedValues:[JIRAAllowedValue]?
    
    func applyData(data:[AnyHashable:Any]){
        if let required = data["required"] as? Bool {
            self.required = required
        }
        if let schemaData = data["schema"] as? [AnyHashable:String] {
            let schema = JIRASchema()
            schema.applyData(data: schemaData)
        }
        if let name = data["name"] as? String {
            self.name = name
        }
        if let hasDefaultValue = data["hasDefaultValue"] as? Bool {
            self.hasDefaultValue = hasDefaultValue
        }
        if let allowedValues = data["allowedValues"] as? [[AnyHashable:Any]] {
            var allowedValuesOutput = [JIRAAllowedValue]()
            allowedValues.forEach({ (allowedValueData) in
                let allowedValue = JIRAAllowedValue()
                allowedValue.applyData(data: allowedValueData)
                allowedValuesOutput.append(allowedValue)
            })
            self.allowedValues = allowedValuesOutput
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
        if let id = data["id"] as? String {
            self.id = id
        }
        if let key = data["key"] as? String {
            self.key = key
        }
        if let name = data["name"] as? String {
            self.name = name
        }
        if let issueTypes = data["issuetypes"] as? [[AnyHashable:Any]] {
            var issueTypesOutput = [JIRAIssueType]()
            issueTypes.forEach({ (issueTypeData) in
                let issueType = JIRAIssueType()
                issueType.applyData(data: issueTypeData)
                issueTypesOutput.append(issueType)
            })
            self.issueTypes = issueTypesOutput
        }
    }
}
