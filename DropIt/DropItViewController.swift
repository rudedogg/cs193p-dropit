//
//  DropItViewController.swift
//  DropIt
//
//  Created by Austin Rude on 9/18/15.
//  Copyright © 2015 Appliest LLC. All rights reserved.
//

import UIKit

class DropItViewController: UIViewController, UIDynamicAnimatorDelegate {

    @IBAction func drop(sender: UITapGestureRecognizer) {
        drop()
    }
    @IBAction func grabDrop(sender: UIPanGestureRecognizer) {
       let gesturePoint = sender.locationInView(gameView)
        switch sender.state {
        case .Began:
            if let viewToAttachTo = lastDroppedView {
            attachment = UIAttachmentBehavior(item: viewToAttachTo, attachedToAnchor: gesturePoint)
            lastDroppedView = nil
            }
        case .Changed:
            attachment?.anchorPoint = gesturePoint
        case .Ended:
            attachment = nil
        default:
            attachment = nil
        }
    }
    @IBOutlet weak var gameView: BezierPathsView!
    
    let dropItBehavior = DropItBehavior()
    
    var lastDroppedView: UIView?
    
    var attachment: UIAttachmentBehavior? {
        willSet {
            if attachment != nil {
                animator.removeBehavior(attachment!)
                gameView.setPath(nil, named: "Handle")
            }
        }
        
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment!)
                attachment?.action = { [unowned self] in
                    if let attachedView = self.attachment?.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint(self.attachment!.anchorPoint)
                        path.addLineToPoint(attachedView.center)
                        self.gameView.setPath(path, named: "Handle")
                    }
                }
            }
        }
    }
    
    
    lazy var animator: UIDynamicAnimator = {
        let lazyDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyDynamicAnimator.delegate = self
        return lazyDynamicAnimator
    }()
    
    override func viewDidLoad() {
        animator.addBehavior(dropItBehavior)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let barrierSize = dropSize
        let barrierOrigin = CGPoint(x: gameView.bounds.midX-barrierSize.width/2, y: gameView.bounds.midY-barrierSize.height/2)
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
        dropItBehavior.addBarrier(path, named: "invisibleCircle")
        gameView.setPath(path, named: "invisibleCircle")
    }
    
    var dropsPerRow = 10
    
    var dropSize: CGSize {
        let size = gameView.bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
    func drop() {
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let dropView = UIView(frame: frame)
        dropView.backgroundColor = UIColor.random
        
        lastDroppedView = dropView
        
        dropItBehavior.addDrop(dropView)
    }
    
    func removeCompletedRow() {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize.width, height: dropSize.height)
        
        repeat {
            dropFrame.origin.y -= dropSize.height
            dropFrame.origin.x = 0
            var dropsFound = [UIView]()
            var rowIsComplete = true
            for _ in 0 ..< dropsPerRow {
                if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil) {
                    if hitView.superview == gameView {
                        dropsFound.append(hitView)
                    }
                    else {
                        rowIsComplete = false
                    }
                }
                dropFrame.origin.x += dropSize.width
            }
            if rowIsComplete {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && dropFrame.origin.y > 0
        
        for drop in dropsToRemove {
            dropItBehavior.removeDrop(drop)
        }
    }

}

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

private extension UIColor {
    class var random: UIColor {
        switch arc4random()%5 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        default: return UIColor.blackColor()
        }
    }
}
