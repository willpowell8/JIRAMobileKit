//
//  JiraImageViewController.swift
//  Pods
//
//  Created by Will Powell on 09/08/2017.
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
        /*canvas!.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }*/
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
