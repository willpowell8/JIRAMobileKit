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

class JIRATextCell:JIRACell{
    override func setup(){
        
    }
}
