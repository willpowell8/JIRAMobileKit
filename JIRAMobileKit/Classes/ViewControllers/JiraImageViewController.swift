//
//  JiraImageViewController.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//

import UIKit

protocol JiraImageViewControllerDelegate {
    func updateImage(image:UIImage, attachmentID:Int)
}

class JiraImageViewController: UIViewController {
    
    var canvas:AnnoateImageView?
    var image:UIImage? {
        didSet{
            canvas?.image = image
        }
    }
    var attachmentID:Int?
    var delegate:JiraImageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        self.navigationItem.title = "Annotate Image"
        canvas = AnnoateImageView()
        canvas?.clearCanvas(animated:false)
        canvas?.drawColor = .red
        canvas?.isUserInteractionEnabled = true
        self.view.addSubview(canvas!)
        if #available(iOS 9.0, *) {
            canvas?.translatesAutoresizingMaskIntoConstraints = false
            canvas?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant:10).isActive = true
            canvas?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant:-10).isActive = true
            canvas?.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant:-20).isActive = true
            canvas?.topAnchor.constraint(equalTo: self.view.topAnchor, constant:10).isActive = true
        }
        canvas?.contentMode = .scaleAspectFit
        canvas?.image = image
        let applyButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(apply))
        self.navigationItem.rightBarButtonItems = [applyButton]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @objc func apply(){
        self.delegate?.updateImage(image: self.canvas!.image!,attachmentID: attachmentID ?? 0)
        self.navigationController?.popViewController(animated: true)
    }

}
