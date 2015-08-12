//
//  ViewController.swift
//  Swipey
//
//  Created by Diego Doval on 3/27/15.
//  Copyright (c) 2015 The Web Electric Corp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, CardStackDelegate {
    
    @IBOutlet weak var cardStackView:CardStack!
    
    let colors:[UIColor] = [UIColor.redColor(), UIColor.blueColor(), UIColor.greenColor(), UIColor.yellowColor(), UIColor.magentaColor(), UIColor.purpleColor(), UIColor.blackColor()]
    
    var actionBar:UIView = UIView()
    
    let imageNames:[String] = ["demo","demo2","demo3","demo","demo2","demo3", "demo"]
    
    var cardCount: Int {
        return self.colors.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardStackView.delegate = self
        self.cardStackView.updateStack()
        
        self.addActionBar()

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func cardRemoved(card: Card) {
        println("The card \(card.cardId!) was removed!")
    }
    
    func toggleActionBarVisibility() {
        println("action bar toggled")
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.actionBar.alpha = -self.actionBar.alpha
        })
        
        
    }
    
    func cardAtIndex(index: Int, frame: CGRect) -> Card {
        
        let card: Card = Card(frame: frame)
        
        let cardImageView = UIImageView(frame: card.frame)
        card.image = UIImage(named: imageNames[index])
        card.contentMode = UIViewContentMode.ScaleAspectFill
        card.clipsToBounds = true
        
        card.backgroundColor = UIColor(red: 0, green: 0, blue: 240, alpha: 0.5)
        card.cardId = String("\(index)")
        
        let label: UILabel = UILabel(frame: card.frame)
        label.text = card.cardId
        label.textColor = UIColor.redColor()
        label.textAlignment = NSTextAlignment.Center
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("cardTapped:"))
        tap.delegate = self
        card.addGestureRecognizer(tap)
        
      //  card.addSubview(cardImageView)
        card.addSubview(label)
        
        return card
        
    }
    
    
    func addActionBar(){
        actionBar = UIView(frame: CGRectMake(0,self.view.frame.height-60,self.view.frame.width,60))
        actionBar.backgroundColor = UIColor.whiteColor()
        actionBar.alpha = 0.8
        
        let buttonTitles = ["edit", "camera", "share", "list"]
        var xPosOffset:CGFloat = -140
        
        
        for buttonTitle in buttonTitles {
            
            let label: UILabel = UILabel(frame: actionBar.frame)
            label.text = buttonTitle
            label.textColor = UIColor.redColor()
            label.textAlignment = NSTextAlignment.Center
            actionBar.addSubview(label)
            label.centerInSuperview()
            label.center.x = label.center.x + xPosOffset
            xPosOffset += 70
            
        }
        self.view.insertSubview(actionBar, aboveSubview: cardStackView)

        
        println("added Action Bar")
    }
    
    func cardTapped(sender: UITapGestureRecognizer){
        println("tap!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

