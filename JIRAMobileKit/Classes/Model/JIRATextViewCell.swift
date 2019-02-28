//
//  JIRATextViewCell.swift
//  JIRAMobileKit
//
//  Created by Will Powell on 18/01/2019.
//

import Foundation

class JIRATextViewCell:JIRACell{
    var textField:PlaceUITextField?
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
        textField = PlaceUITextField()
        textField?.placeholder = "enter value"
        textField?.font = UIFont.systemFont(ofSize: 17)
        self.addSubview(textField!)
        textField?.translatesAutoresizingMaskIntoConstraints = false
        textField?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 11).isActive = true
        textField?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -23).isActive = true
        textField?.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant:-3).isActive = true
        textField?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:0).isActive = true
        textField?.textColor = JIRA.MainColor
        textField?.delegate = self
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

import UIKit

@IBDesignable
 class PlaceUITextField: UITextView {
    
    private struct Constants {
        static let defaultiOSPlaceholderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22)
    }
    public let placeholderLabel: UILabel = UILabel()
    
    private var placeholderLabelConstraints = [NSLayoutConstraint]()
    
    @IBInspectable open var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    @IBInspectable open var placeholderColor: UIColor = PlaceUITextField.Constants.defaultiOSPlaceholderColor {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    override open var font: UIFont! {
        didSet {
            if placeholderFont == nil {
                placeholderLabel.font = font
            }
        }
    }
    
    open var placeholderFont: UIFont? {
        didSet {
            let font = (placeholderFont != nil) ? placeholderFont : self.font
            placeholderLabel.font = font
        }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    override open var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override open var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    
    override open var textContainerInset: UIEdgeInsets {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)
        self.textColor = .black
        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.text = placeholder
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        updateConstraintsForPlaceholderLabel()
    }
    
    
    private func updateConstraintsForPlaceholderLabel() {
        var newConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(textContainerInset.left + textContainer.lineFragmentPadding))-[placeholder]",
            options: [],
            metrics: nil,
            views: ["placeholder": placeholderLabel])
        newConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(textContainerInset.top))-[placeholder]",
            options: [],
            metrics: nil,
            views: ["placeholder": placeholderLabel])
        newConstraints.append(NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 1.0,
            constant: -(textContainerInset.left + textContainerInset.right + textContainer.lineFragmentPadding * 2.0)
        ))
        removeConstraints(placeholderLabelConstraints)
        addConstraints(newConstraints)
        placeholderLabelConstraints = newConstraints
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UITextView.textDidChangeNotification,
                                                  object: nil)
    }
    
}

