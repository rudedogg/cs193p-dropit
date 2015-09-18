//
//  BezierPathsView.swift
//  DropIt
//
//  Created by Austin Rude on 9/18/15.
//  Copyright © 2015 Appliest LLC. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {


    private var bezierPaths = [String:UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        for (_, path) in bezierPaths {
           path.stroke()
        }
        
    }

}
