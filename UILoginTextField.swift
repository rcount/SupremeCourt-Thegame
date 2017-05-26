//
//  LoginTextField.swift
//  ProofOfConcept
//
//  Created by Stephen Vickers on 2/8/17.
//  Copyright © 2017 Stephen Vickers. All rights reserved.
//

import UIKit

@IBDesignable
class UILoginTextField: UITextField {

    @IBInspectable var leftImage : UIImage? {
        didSet{
            self.updateView()
        }
    }

    @IBInspectable var leftImagePadding : CGFloat = 5.0{
        didSet{
            self.updateView()
        }
    }


    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius

        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet {
            self.updateShadow()
        }
    }

    @IBInspectable var shadowOpacity: Float = 1.0 {
        didSet {
            self.updateShadow()
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            self.updateShadow()
        }
    }


    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet{
            self.updateShadow()
        }
    }

    private func updateView(){

        if let image = leftImage{
            leftViewMode = .always

            let imageView = UIImageView(frame: CGRect(x: self.leftImagePadding, y: 0, width: 20, height: 20))
            imageView.image = leftImage

            var width = self.leftImagePadding + 20

            if borderStyle == UITextBorderStyle.none || borderStyle == UITextBorderStyle.line{
                width += 5
            }

            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
            view.addSubview(imageView)
            leftView = view
        }
        else{

            if borderStyle == UITextBorderStyle.none || borderStyle == UITextBorderStyle.line {
                leftViewMode = .always
                let view = UIView(frame: CGRect(x: 5, y: 0, width: 5, height: 0))
                leftView = view
            }
        }
    }

    private func updateShadow(){
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.masksToBounds = false
    }
}
