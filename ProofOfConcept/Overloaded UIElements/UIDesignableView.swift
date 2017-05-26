//
//  UIDesignableView.swift
//  ProofOfConcept
//
//  Created by Stephen Vickers on 2/14/17.
//  Copyright © 2017 Stephen Vickers. All rights reserved.
//

import UIKit

class UIDesignableView: UIView {

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

    private func updateShadow(){
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.masksToBounds = false
    }

}
