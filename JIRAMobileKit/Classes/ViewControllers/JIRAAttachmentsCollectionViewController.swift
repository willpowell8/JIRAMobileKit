//
//  JIRAAttachmentsCollectionViewController.swift
//  JIRAMobileKit
//
//  Created by Will Powell on 04/10/2017.
//

import UIKit
import QuickLook

private let reuseIdentifier = "Cell"

class JIRAAttachmentsCollectionViewController: UICollectionViewController {
    
    let quickLookController = QLPreviewController()
    var quickLookSelected = [QLPreviewItem]()
    
    var attachments = [Any]()
    var delegate:JIRASubTableViewControllerDelegate?
    var field:JIRAField? {
        didSet{
            if let f = field {
                self.navigationItem.title = f.name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.collectionView?.backgroundColor = .clear
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(JIRAImageCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        //let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        self.navigationItem.rightBarButtonItems = [addButton]//,editButton]
    }
    
    @objc func add(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    func edit(){
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return attachments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! JIRAImageCollectionCell
    
        let item = self.attachments[indexPath.row]
        cell.applyData(item)
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let any  = self.attachments[indexPath.row]
        if let image = any as? UIImage {
            let jiraImageVC = JiraImageViewController()
            jiraImageVC.image = image
            jiraImageVC.attachmentID = indexPath.row
            jiraImageVC.delegate = self
            self.navigationController?.pushViewController(jiraImageVC, animated: true)
        }else if let urlString = any as? String, let url = URL(string:urlString){
            let filePreview = url as QLPreviewItem
            quickLookSelected = [filePreview]
            quickLookController.delegate = self
            quickLookController.dataSource = self
            quickLookController.reloadData()
            self.present(quickLookController, animated: true, completion: nil)
        }else if let url =  any as? URL{
            let filePreview = url as QLPreviewItem
            quickLookSelected = [filePreview]
            quickLookController.delegate = self
            quickLookController.dataSource = self
            quickLookController.reloadData()
            self.present(quickLookController, animated: true, completion: nil)
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension JIRAAttachmentsCollectionViewController:UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.attachments.append(image)
            DispatchQueue.main.async {
                self.delegate?.jiraSelected(field:self.field, item: self.attachments)
                self.collectionView?.reloadData()
            }
        }
        dismiss(animated:true, completion: nil)
    }
}

extension JIRAAttachmentsCollectionViewController:UINavigationControllerDelegate{
    
}


extension JIRAAttachmentsCollectionViewController:QLPreviewControllerDelegate, QLPreviewControllerDataSource{
    // MARK: - Preview controller datasource  functions
    
    func numberOfPreviewItems(in: QLPreviewController) -> Int {
        return quickLookSelected.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return quickLookSelected[index]
    }
    
    // MARK: - Preview controller delegate functions
    
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        
    }
    
    func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
        return true
    }
}

extension JIRAAttachmentsCollectionViewController:JiraImageViewControllerDelegate {
    func updateImage(image: UIImage, attachmentID:Int) {
        attachments[attachmentID] = image
        collectionView?.reloadData()
        self.delegate?.jiraSelected(field:self.field, item: self.attachments)
    }
}
