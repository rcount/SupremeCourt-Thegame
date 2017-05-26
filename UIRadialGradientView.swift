//
//  UIRadialGradientView.swift
//  ProofOfConcept
//
//  Created by Stephen Vickers on 2/3/17.
//  Copyright © 2017 Stephen Vickers. All rights reserved.
//

import UIKit


@IBDesignable
class UIRadialGradientView: UIView {

    @IBInspectable var innerColor : UIColor = UIColor.clear
    @IBInspectable var outerColor : UIColor = UIColor.clear

    override func draw(_ rect: CGRect) {
        let colors = [innerColor.cgColor, outerColor.cgColor] as CFArray
        
        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil)
        let endRadius = min(frame.width, frame.height) / 2
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        
        UIGraphicsGetCurrentContext()!.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: endRadius, options: CGGradientDrawingOptions.drawsAfterEndLocation)
    }

}
