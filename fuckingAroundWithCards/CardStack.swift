//
//  Copyright (c) 2015 The Web Electric Corp. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    public func centerInSuperview() {
        if let superview = self.superview {
            let parentBounds = superview.bounds
            let x = parentBounds.size.width/2
            let y = parentBounds.size.height/2
            self.center = CGPoint(x: x, y: y)
        }
    }
    
    public func setShadowAndCorners(cornerRadius: Int = 8, shadowOffset: CGSize = CGSize(width: 0, height: 8), shadowColor: UIColor = UIColor.blackColor(), shadowRadius: Int = 8, shadowOpacity: Float = 0.4) {
        let layer = self.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = CGFloat(shadowRadius)
        
        layer.cornerRadius = CGFloat(cornerRadius)
        
    }
}

public typealias PanGestureAction = (UIPanGestureRecognizer!) -> Void
public typealias SwipeGestureAction = (UISwipeGestureRecognizer!) -> Void
public typealias TapGestureAction = (UITapGestureRecognizer!) -> Void

class GestureView : UIView, UIGestureRecognizerDelegate {
    private(set) var swipeGestureRecognizer: UISwipeGestureRecognizer! = nil
    private(set) var panGestureRecognizer: UIPanGestureRecognizer! = nil
    private(set) var tapGestureRecognizer: UITapGestureRecognizer! = nil
    
    var panAction:PanGestureAction? = nil
    var tapAction:TapGestureAction? = nil
   // var swipeAction:SwipeGestureAction? = nil
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    internal required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = true
        
        //        self.swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        //        swipeGestureRecognizer.cancelsTouchesInView = false
        //        self.swipeGestureRecognizer.direction = .Up
        //        addGestureRecognizer(self.swipeGestureRecognizer)
        
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        self.panGestureRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(self.panGestureRecognizer)
        self.panGestureRecognizer.delegate = self

        
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        addGestureRecognizer(self.tapGestureRecognizer)
        self.tapGestureRecognizer.delegate = self
        
        //        self.swipeGestureRecognizer.requireGestureRecognizerToFail(self.panGestureRecognizer)
        
        //        tapGestureRecognizer.requireGestureRecognizerToFail(swipeGestureRecognizer)
        
    }
    
    
    internal func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if (gestureRecognizer == self.panGestureRecognizer || gestureRecognizer == self.tapGestureRecognizer) {
            return true
        }
        return false
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if let panAction = self.panAction {
            panAction(recognizer)
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        if let tapAction = self.tapAction {
            tapAction(recognizer)
        }
    }
    
//    func handleSwipe(recognizer: UISwipeGestureRecognizer) {
//        if let swipeAction = self.swipeAction {
//            swipeAction(recognizer)
//        }
//    }
}
///superclass for the views that will display the actual cards.
///The cardId property is used to identify the card when the delegate gets
///a callback with the card information
public class Card : UIImageView {
    var cardId: String? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public protocol CardStackDelegate {
    var cardCount: Int { get }
    
    func cardAtIndex(index: Int, frame: CGRect) -> Card
    
    func toggleActionBarVisibility()
    
    func cardRemoved(card: Card)
}

public class CardStack : UIView {
    
    //make these properties read-only outside of this class
    private(set) var panGestureRecognizer: UIPanGestureRecognizer! = nil
    private(set) var swipeGestureRecognizer: UISwipeGestureRecognizer! = nil
    
    private(set) lazy var topView: UIView = UIView()
    var topCard: Card! = nil
    private(set) lazy var hiddenView: UIView = UIView()
    var hiddenCard: Card! = nil
    private(set) lazy var bottomView: UIView = UIView()
    var gestureView:GestureView! = nil
    
    private(set) lazy var hintView: UIImageView = UIImageView()
    private(set) lazy var darkView: UIView = UIView()
    
    let cardTag = 72
    
    public var delegate: CardStackDelegate? = nil
    public var noMoreCardsView: UIView = {
        //default 'noMoreCards' View
        let noMoreCards: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        noMoreCards.backgroundColor = UIColor.whiteColor()
        noMoreCards.backgroundColor = UIColor.lightGrayColor()
        
        let label: UILabel = UILabel(frame: noMoreCards.frame)
        label.text = "No more cards!"
        label.textColor = UIColor.redColor()
        label.textAlignment = NSTextAlignment.Center
        
        noMoreCards.addSubview(label)
        
        return noMoreCards
        }() {
        //override setter to replace view in our hierarchy
        didSet {
            self.insertSubview(noMoreCardsView, atIndex: 0)
            self.bottomView.centerInSuperview()
            oldValue.removeFromSuperview()
        }
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.clearColor()
        
        self.bottomView.addSubview(self.noMoreCardsView)
        self.addSubview(self.bottomView)
        self.addSubview(self.hiddenView)
        self.addSubview(self.topView)
        self.addHintViews()
        
        self.gestureView = GestureView(frame: self.bounds)
        
        self.addSubview(self.gestureView)
        
        self.topView.setShadowAndCorners()
        self.hiddenView.setShadowAndCorners()
        self.bottomView.setShadowAndCorners()
        
        //    209,219,221
        #if DEBUG
            self.topView.backgroundColor = UIColor(red: 209, green: 219, blue: 221, alpha: 1)
            self.hiddenView.backgroundColor = UIColor(red: 209, green: 219, blue: 221, alpha: 1)
            self.bottomView.backgroundColor = UIColor(red: 209, green: 219, blue: 221, alpha: 1)
            #else
            self.topView.backgroundColor = UIColor.whiteColor()
            self.hiddenView.backgroundColor = UIColor.whiteColor()
            self.bottomView.backgroundColor = UIColor.whiteColor()
        #endif
        
        
        self.updateViewTreeBounds()
        
        
        self.gestureView.panAction = { [unowned self] (recognizer: UIPanGestureRecognizer!) -> Void in
            //            println("pan \(recognizer.locationInView(self))")
            self.handlePanAndSwipe(recognizer)
        }
        
        self.gestureView.tapAction = { [unowned self] (recognizer: UITapGestureRecognizer!) -> Void in
            self.handleTap(recognizer)
        }
        
//        self.gestureView.swipeAction = { (recognizer: UISwipeGestureRecognizer!) -> Void in
//            //            println("swipe \(recognizer.locationInView(self))")
//        }
        
        
    }
    
    override public var bounds: CGRect {
        didSet {
            self.updateViewTreeBounds()
        }
    }
    
    private func updateViewTreeBounds() {
        
        println("f = \(self.frame)")
        println("b = \(self.bounds)")
        self.topView.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        self.hiddenView.bounds = self.topView.bounds
        self.bottomView.bounds = self.topView.bounds
        self.gestureView.bounds = self.topView.bounds
        
        self.gestureView.centerInSuperview()
        self.topView.centerInSuperview()
        self.hiddenView.centerInSuperview()
        self.bottomView.centerInSuperview()
        self.noMoreCardsView.centerInSuperview()
        hintView.centerInSuperview()
        darkView.centerInSuperview()

        
        
    }
    
    func addHintViews(){
        
        darkView = UIView(frame: UIScreen.mainScreen().bounds)
        var newFrame = darkView.frame
        newFrame.size.height = newFrame.size.height+20
        darkView.frame = newFrame
        darkView.alpha = 0
        darkView.backgroundColor = UIColor.blackColor()
        self.addSubview(darkView)
        
        hintView = UIImageView(image: UIImage(named: "nope"))
        hintView.bounds = CGRectMake(0,0,80,80)
        hintView.alpha = 0
        hintView.frame.origin.y = -0
        self.addSubview(hintView)
        
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
    }
    
    func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        
    }
    
    var actionViewOriginalCenter: CGPoint = CGPointZero
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        println("tap")
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.delegate?.toggleActionBarVisibility()
        })
        
        
        
    }
    
    func handlePanAndSwipe(recognizer: UIPanGestureRecognizer) {
        if (self.topView.alpha == 0) {
            return
        }
        let actionView = self.topView
        
        if (recognizer.state == UIGestureRecognizerState.Began) {
            self.actionViewOriginalCenter = actionView.center
            return
        }
        
        let swipeUpThreshold:CGFloat = -1000.0
        let swipeDownThreshold:CGFloat = 1000.0
        let swipeLeftThreshold:CGFloat = -1000.0
        let swipeRightThreshold:CGFloat = 1000.0
        
        let t = recognizer.translationInView(recognizer.view!)
        recognizer.setTranslation(CGPointZero, inView: recognizer.view)
        /*
        //for generalizing later ie to also allow horizontal panning/swipe
        //        let allowHorizontalMovement = false
        //        let xTranslation:CGFloat = allowHorizontalMovement ? actionView.center.x + t.x : actionView.center.x
        */
        
        let xTranslation:CGFloat = actionView.center.x
        let yTranslation:CGFloat = actionView.center.y + t.y
        
        actionView.center = CGPoint(x: xTranslation, y: yTranslation)
        self.hintView.center = actionView.center
        
        
        let minOpacityChangeDistance:CGFloat = 0
        let swipeOutThreshold = (actionView.frame.height/3)
        let verticalDistanceTraveled = abs(abs(self.actionViewOriginalCenter.y) - abs(actionView.center.y))
        let verticalDistanceFromCenter = abs(self.actionViewOriginalCenter.y) - abs(actionView.center.y)
        
        if (verticalDistanceTraveled > minOpacityChangeDistance && verticalDistanceTraveled < swipeOutThreshold && recognizer.state != UIGestureRecognizerState.Ended) {
            let alphaValue = 0.75 + 0.25 - (0.25 * verticalDistanceTraveled/swipeOutThreshold)
            let darkValue = (0.6 * verticalDistanceTraveled/swipeOutThreshold)
            let hintAlphaValue = verticalDistanceTraveled/swipeOutThreshold
            var angle:CGFloat = 0.20 * verticalDistanceTraveled/swipeOutThreshold
            if actionView.center.y > self.actionViewOriginalCenter.y {
                angle = -angle
            }
            var transform = CGAffineTransformMakeTranslation(0,0)
            transform = CGAffineTransformRotate(transform, angle)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if actionView.center.y > self.actionViewOriginalCenter.y {
                    self.hintView.image = UIImage(named: "nope")
                }
                else {
                    self.hintView.image = UIImage(named: "yup")
                }
                actionView.alpha = alphaValue
                self.hintView.alpha = hintAlphaValue
                self.darkView.alpha = darkValue
                actionView.transform = transform
            })
        }
        else if (verticalDistanceTraveled <= minOpacityChangeDistance) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                actionView.alpha = 1
                self.hintView.alpha = 0
                self.darkView.alpha = 0
                var transform = CGAffineTransformMakeTranslation(0,0)
                transform = CGAffineTransformRotate(transform, 0)
                actionView.transform = transform
            })
        }
        
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            println(verticalDistanceFromCenter)
            self.hintView.alpha = 0
            self.darkView.alpha = 0




            println(swipeOutThreshold)
            let velocity = recognizer.velocityInView(recognizer.view)
            if (velocity.y < swipeUpThreshold) {
                println("swipe up")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.swipeUpTopCard()
                })
            }
            else if (velocity.y > swipeDownThreshold) {
                println("swipe down")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.swipeDownTopCard()
                })
            }
            else {
                if (verticalDistanceFromCenter > swipeOutThreshold) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        println("up further than threshold")
                        self.swipeUpTopCard()
                    })
                }
                else if (verticalDistanceFromCenter < -swipeOutThreshold) {
                    println("down further than threshold")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.swipeDownTopCard()
                    })
                }
                    
                
                else {
                    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn,
                        animations: { () -> Void in
                            
                            actionView.center = self.actionViewOriginalCenter
                            actionView.alpha = 1
                            var transform = CGAffineTransformMakeTranslation(0,0)
                            transform = CGAffineTransformRotate(transform, 0)
                            actionView.transform = transform
                            
                        },
                        completion: { (done: Bool) -> Void in
                            
                            
                            
                    })
                }

                
                //action + lift, animate to snap view back into position
            }
            var transform = CGAffineTransformMakeTranslation(0,0)
            transform = CGAffineTransformRotate(transform, 0)
            actionView.transform = transform
        }
    }
    
    var indexOfTopCard = 0
    ///triggers a calculation/recalculation of cardstack internals after setting the delegate or after data has changes
    public func updateStack() {
        if let delegate = self.delegate {
            
            let cardCount:Int = delegate.cardCount
            
            self.indexOfTopCard = 0
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (cardCount > 0) {
                    self.setCardToView(0, view: self.topView)
                    self.topView.alpha = 1
                }
                else {
                    self.topView.alpha = 0
                }
                
                
                if (cardCount > 1) {
                    self.setCardToView(1, view: self.hiddenView)
                    self.hiddenView.alpha = 1
                }
                else {
                    self.hiddenView.alpha = 0
                }
                
                
                self.adjustVerticalForCardsLeft(cardCount)
            })
            
        }
        else {
            fatalError("Delegate not set!")
        }
    }
    
    func adjustVerticalForCardsLeft(cardsLeft: Int) {
//        if (cardsLeft == 2) {
//            var center = self.topView.center
//            center.y = (self.topView.superview!.bounds.height/2)-12
//            self.topView.center = center
//            self.hiddenView.centerInSuperview()
//        }
//        else if (cardsLeft >= 3) {
//            var center = self.topView.center
//            center.y = (self.topView.superview!.bounds.height/2)-24
//            self.topView.center = center
//            var center2 = self.hiddenView.center
//            center2.y = (self.hiddenView.superview!.bounds.height/2)-12
//            self.hiddenView.center = center2
//        }
//        else {
//            self.topView.centerInSuperview()
//            self.hiddenView.centerInSuperview()
//        }
        
    }
    
    func setCardToView(cardIndex: Int, view: UIView) {
        if let delegate = self.delegate {
            println("setting card \(cardIndex)")
            assert(view.subviews.count == 0, "view for adding card has subviews!")
            let card = delegate.cardAtIndex(cardIndex, frame: view.frame)
            card.tag = self.cardTag
            view.addSubview(card)
            card.centerInSuperview()
        }
    }
    
    func enlargeCurrentCard() {
        let actionView = self.topView
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            
            var theBounds = actionView.bounds
            let theCenter = actionView.center
            theBounds.size.height = theBounds.size.height + 50
            actionView.bounds = theBounds
            actionView.clipsToBounds = false
            actionView.setNeedsDisplay()
            
            
//            actionView.frame = UIScreen.mainScreen().bounds
//            let size = UIScreen.mainScreen().bounds.size
//            actionView.frame.size = size
        })
    }
    
    func swipeDownTopCard() {
        let actionView = self.topView
        let newTopView = self.hiddenView
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                
                actionView.center = CGPoint(x: actionView.center.x, y: 2*(actionView.frame.height))
                
            },
            completion: { (done: Bool) -> Void in
                
                if (done) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let currentCard = actionView.viewWithTag(self.cardTag) as! Card
                        currentCard.removeFromSuperview()
                        let cardCount = self.delegate!.cardCount
                        
                        let wasAtLastCard = cardCount == self.indexOfTopCard+1
                        
                        self.indexOfTopCard++
                        
                        if (wasAtLastCard) {
                            //if we just removed the last card simply hide the topview and return it to center
                            //the hiddenview should have been hidden in the previous step
                            self.topView.alpha = 0
                            self.topView.centerInSuperview()
                        }
                        else {
                            self.hintView.alpha = 0
                            self.topView = newTopView
                            actionView.removeFromSuperview()
                            self.hiddenView = actionView
                            self.insertSubview(self.hiddenView, atIndex: 1)
                            self.hiddenView.centerInSuperview()
                            
                            let hasNextCard = cardCount > (self.indexOfTopCard+1)
                            
                            if (hasNextCard) {
                                //                                println("Set card index \(self.indexOfTopCard+1) as hidden")
                                self.setCardToView(self.indexOfTopCard+1, view: self.hiddenView)
                                self.hiddenView.alpha = 1
                            }
                            else {
                                self.hiddenView.alpha = 0
                            }
                            //                            println("top card id is \(self.indexOfTopCard)")
                            
                            UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,
                                animations: { () -> Void in
                                    let cardsLeft = cardCount - self.indexOfTopCard
                                    println("cards left = \(cardsLeft)")
                                    self.adjustVerticalForCardsLeft(cardsLeft)
                                    
                                }, completion: { (done: Bool) -> Void in
                                    
                            })
                        }
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                            self.delegate?.cardRemoved(currentCard)
                        })
                        
                    })
                }
        })
    }
    
    func swipeUpTopCard() {
        let actionView = self.topView
        let newTopView = self.hiddenView
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                
                actionView.center = CGPoint(x: actionView.center.x, y: -(actionView.frame.height))
                
            },
            completion: { (done: Bool) -> Void in
                
                if (done) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let currentCard = actionView.viewWithTag(self.cardTag) as! Card
                        currentCard.removeFromSuperview()
                        let cardCount = self.delegate!.cardCount
                        
                        let wasAtLastCard = cardCount == self.indexOfTopCard+1
                        
                        self.indexOfTopCard++
                        
                        if (wasAtLastCard) {
                            //if we just removed the last card simply hide the topview and return it to center
                            //the hiddenview should have been hidden in the previous step
                            self.topView.alpha = 0
                            self.topView.centerInSuperview()
                        }
                        else {
                            self.hintView.alpha = 0

                            self.topView = newTopView
                            actionView.removeFromSuperview()
                            self.hiddenView = actionView
                            self.insertSubview(self.hiddenView, atIndex: 1)
                            self.hiddenView.centerInSuperview()
                            
                            let hasNextCard = cardCount > (self.indexOfTopCard+1)
                            
                            if (hasNextCard) {
                                //                                println("Set card index \(self.indexOfTopCard+1) as hidden")
                                self.setCardToView(self.indexOfTopCard+1, view: self.hiddenView)
                                self.hiddenView.alpha = 1
                            }
                            else {
                                self.hiddenView.alpha = 0
                            }
                            //                            println("top card id is \(self.indexOfTopCard)")
                            
                            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,
                                animations: { () -> Void in
                                    let cardsLeft = cardCount - self.indexOfTopCard
                                    println("cards left = \(cardsLeft)")
                                    self.adjustVerticalForCardsLeft(cardsLeft)
                                    
                                }, completion: { (done: Bool) -> Void in
                                    
                            })
                        }
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                            self.delegate?.cardRemoved(currentCard)
                        })
                        
                    })
                }
        })
    }

    
    
    
}