//
//  JiraImageViewController.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//

import UIKit

protocol JiraImageViewControllerDelegate {
    func updateImage(image:UIImage)
}

class JiraImageViewController: UIViewController {
    
    var canvas:AnnoateImageView?
    var image:UIImage? {
        didSet{
            canvas?.image = image
        }
    }
    var delegate:JiraImageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        canvas = AnnoateImageView()
        canvas?.clearCanvas(animated:false)
        canvas?.drawColor = .red
        canvas?.isUserInteractionEnabled = true
        self.view.addSubview(canvas!)
        if #available(iOS 9.0, *) {
            canvas?.translatesAutoresizingMaskIntoConstraints = false
            canvas?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            canvas?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            canvas?.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
            canvas?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        }
        canvas?.image = image
        let applyButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(apply))
        self.navigationItem.rightBarButtonItems = [applyButton]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func apply(){
        self.delegate?.updateImage(image: self.canvas!.image!)
        self.navigationController?.popViewController(animated: true)
    }

}
