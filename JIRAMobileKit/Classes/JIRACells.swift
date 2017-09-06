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
    
    func deselect(){
        
    }
    
    func applyData(data:[String:Any]){
        
    }
    
    func height()->CGFloat{
        return 44
    }
}


class JIRATextFieldCell:JIRACell{
    var textField:UITextField?
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected == true {
            self.textField?.becomeFirstResponder()
        }else{
            self.textField?.resignFirstResponder()
        }
    }
    override func setup(){
        textField = UITextField()
        textField?.placeholder = "enter value"
        textField?.textAlignment = .right
        self.addSubview(textField!)
        textField?.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 9.0, *) {
            textField?.leftAnchor.constraint(equalTo: self.textLabel!.leftAnchor, constant: 100).isActive = true
            textField?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
            textField?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            textField?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        textField?.textColor = JIRA.MainColor
        self.textLabel?.backgroundColor = .red
        textField?.addTarget(self, action: #selector(didChangeTextfield), for: UIControlEvents.editingChanged)
    }
    
    override func applyData(data:[String:Any]){
        if let field = field, let identifier = field.identifier {
            if let element = data[identifier] as? String {
                self.textField?.text = element
            }
        }
    }
    
    override func deselect() {
        super.deselect()
        self.textField?.resignFirstResponder()
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
        self.detailTextLabel?.textColor = JIRA.MainColor
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


class JIRAImageCell:JIRACell{
    var imageViewArea:UIImageView?
    override func setup(){
        self.accessoryType = .disclosureIndicator
        imageViewArea = UIImageView()
        imageViewArea?.backgroundColor = .clear
        self.addSubview(imageViewArea!)
        imageViewArea?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            imageViewArea?.leftAnchor.constraint(equalTo: self.textLabel!.rightAnchor, constant: 20).isActive = true
            imageViewArea?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
            imageViewArea?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
            imageViewArea?.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        }
        imageViewArea?.contentMode = .scaleAspectFit
        self.backgroundColor = UIColor.init(white: 0.95, alpha: 1.0)
    }
    
    override func applyData(data:[String:Any]){
        if let field = field, let identifier = field.identifier {
            if let element = data[identifier] as? UIImage {
                self.imageViewArea?.image = element
            }
        }
    }
    
    override func height()->CGFloat{
        return 200
    }
}
