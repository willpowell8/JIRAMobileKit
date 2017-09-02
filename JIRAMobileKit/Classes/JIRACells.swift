//
//  JIRACells.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//

import Foundation


class JIRACell:UITableViewCell{
    
    var field:JIRAField?
    var delegate:JIRASubTableViewControllerDelegate?
    
    func start(field:JIRAField?, data:[String:Any]?){
        self.field = field
        self.textLabel?.text = field?.name
        self.setup()
        if let data = data {
            self.applyData(data: data)
        }
    }
    
    func setup(){
        
    }
    
    func applyData(data:[String:Any]){
        
    }
    
    func height()->Int{
        return 44
    }
}


class JIRATextFieldCell:JIRACell{
    var textField:UITextField?
    override func setup(){
        textField = UITextField()
        textField?.placeholder = "enter value"
        textField?.textAlignment = .right
        self.addSubview(textField!)
        textField?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            textField?.leftAnchor.constraint(equalTo: self.textLabel!.leftAnchor, constant: 20).isActive = true
            textField?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
            textField?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            textField?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        textField?.addTarget(self, action: #selector(didChangeTextfield), for: UIControlEvents.editingChanged)
        /*if let details = self.details {
            if let value = details["value"] {
                textField?.text = String(describing:value)
            }
        }*/
    }
    
    override func applyData(data:[String:Any]){
        if let field = field, let identifier = field.identifier {
            if let element = data[identifier] as? String {
                self.textField?.text = element
            }
        }
    }
    
    func didChangeTextfield(){
       delegate?.jiraSelected(field: field, item: self.textField?.text)
    }
}


class JIRATextCell:JIRACell{
    override func setup(){
        
    }
}

class JIRAOptionCell:JIRACell{
    override func setup(){
        self.accessoryType = .disclosureIndicator
    }
    
    override func applyData(data:[String:Any]){
        if let field = field, let identifier = field.identifier {
            if let element = data[identifier] as? DisplayClass {
                self.detailTextLabel?.text = element.label
            }else if let elements = data[identifier] as? [DisplayClass] {
                let strs = elements.flatMap({ (element) -> String? in
                    return element.label
                })
                self.detailTextLabel?.text = strs.joined(separator: ", ")
            }
        }
    }
}
