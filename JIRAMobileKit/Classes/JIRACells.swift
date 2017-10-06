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
            textField?.leftAnchor.constraint(equalTo: self.textLabel!.rightAnchor, constant: 10).isActive = true
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


protocol JIRAImageCellDelegate {
    func jiraImageCellSelected(cell:JIRACell,any:Any, index:Int)
}


class JIRAImageCell:JIRACell,UICollectionViewDelegate, UICollectionViewDataSource{
    var collectionView:UICollectionView?
    var attachments:[Any]?
    var delegateSelection:JIRAImageCellDelegate?
    
    override func setup(){
        self.accessoryType = .disclosureIndicator
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.itemSize = CGSize(width: 130, height: 170)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flow)
        self.addSubview(collectionView!)
        //imageViewArea = UIImageView()
        //imageViewArea?.backgroundColor = .clear
        //self.addSubview(imageViewArea!)
        //imageViewArea?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            collectionView?.leftAnchor.constraint(equalTo: self.textLabel!.rightAnchor, constant: 10).isActive = true
            collectionView?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -33).isActive = true
            collectionView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
            collectionView?.topAnchor.constraint(equalTo: self.topAnchor, constant: 1).isActive = true
        }
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .clear
        collectionView?.register(JIRAImageCollectionCell.self, forCellWithReuseIdentifier: "Attachment")
        self.backgroundColor = UIColor.init(white: 0.95, alpha: 1.0)
    }
    
    override func applyData(data:[String:Any]){
        if let field = field, let identifier = field.identifier {
            if let element = data[identifier] as? [Any] {
                attachments = element
                collectionView?.reloadData()
            }
        }
    }
    
    override func height()->CGFloat{
        return 200
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Attachment", for: indexPath) as! JIRAImageCollectionCell
        if let item = attachments?[indexPath.row] {
            cell.applyData(item)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = attachments?[indexPath.row] {
            delegateSelection?.jiraImageCellSelected(cell:self, any: item, index: indexPath.row)
        }
    }
    
}


class JIRAImageCollectionCell:UICollectionViewCell{
    let name = UILabel()
    let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func applyData(_ any:Any){
        if let image = any as? UIImage {
            imageView.image = image
            name.text = "PNG"
        }else if let urlStr = any as? String, let url = URL(string:urlStr){
            name.text =  url.lastPathComponent
        }else if let url = any as? URL{
            name.text =  url.lastPathComponent
        }
    }
    
    func setup(){
        self.addSubview(name)
        self.addSubview(imageView)
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textAlignment = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if #available(iOS 9.0, *) {
            name.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 3).isActive = true
            name.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -3).isActive = true
            name.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
            name.heightAnchor.constraint(equalToConstant: 20) .isActive = true
            
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
            imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -23).isActive = true
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        }
    }
}
