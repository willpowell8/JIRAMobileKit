//
//  JIRATextViewCell.swift
//  JIRAMobileKit
//
//  Created by Will Powell on 18/01/2019.
//

import Foundation

class JIRATextViewCell:JIRACell{
    var textField:UITextView?
    var label:UILabel = UILabel()
    
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
        self.addSubview(label)
        label.text = field?.name
        self.textLabel?.text = ""
        self.textLabel?.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant:10).isActive = true
        textField = UITextView()
        //textField?.placeholder = "enter value"
        self.addSubview(textField!)
        textField?.translatesAutoresizingMaskIntoConstraints = false
        textField?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 13).isActive = true
        textField?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -23).isActive = true
        textField?.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant:-3).isActive = true
        textField?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:0).isActive = true
        textField?.textColor = JIRA.MainColor
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
    
    @objc func didChangeTextfield(){
        delegate?.jiraSelected(field: field, item: self.textField?.text)
    }
    
    override func height()->CGFloat{
        return CGFloat(100)
    }
}

extension JIRATextViewCell:UITextViewDelegate{
     func textViewDidChange(_ textView: UITextView){
        delegate?.jiraSelected(field: field, item: self.textField?.text)
    }
}
