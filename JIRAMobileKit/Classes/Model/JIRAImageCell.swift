//
//  JIRAImageCell.swift
//  JIRAMobileKit
//
//  Created by Will Powell on 11/10/2017.
//

import Foundation
protocol JIRAImageCellDelegate {
    func jiraImageCellSelected(cell:JIRACell,any:Any, index:Int)
}


class JIRAImageCell:JIRACell,UICollectionViewDelegate, UICollectionViewDataSource{
    var collectionView:UICollectionView?
    var attachments:[Any]?
    var delegateSelection:JIRAImageCellDelegate?
    var label = UILabel()
    
    override func setup(){
        
        self.addSubview(label)
        label.text = field?.name
        self.textLabel?.text = ""
        self.textLabel?.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant:10).isActive = true
        self.accessoryType = .disclosureIndicator
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.itemSize = CGSize(width: 120, height: 150)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flow)
        self.addSubview(collectionView!)
        //imageViewArea = UIImageView()
        //imageViewArea?.backgroundColor = .clear
        //self.addSubview(imageViewArea!)
        //imageViewArea?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
        collectionView?.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant: 1).isActive = true
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .clear
        collectionView?.register(JIRAImageCollectionCell.self, forCellWithReuseIdentifier: "Attachment")
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
            name.text = "Image"
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
