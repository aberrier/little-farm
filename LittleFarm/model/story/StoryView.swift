//
//  StoryView.swift
//  LittleFarm
//
//  Created by saad on 27/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

protocol StoryViewDelegate {
    func storyPressButton(sender : StoryButton)
}

class StoryView: UIView {
    
    var dataManager = PersistentDataManager.sharedInstance
    var scenario = StoryScenario.instance
    var delegate : StoryViewDelegate!
    
    @IBOutlet var storyText : LFLabel!
    @IBOutlet var arrowButton : StoryButton!
    @IBOutlet var buttonsArea : UIView!
    
    var isSetted : Bool = false
    var rectArrow : CGRect?
    var rectLabel : CGRect?
    var buttonList : [StoryButton] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup()
    {
        arrowButton.addTarget(self, action: #selector(buttonPress), for: .touchUpInside)
        arrowButton.transformOnClearButton()
        rectLabel = storyText.frame
        rectArrow = arrowButton.frame
        isSetted = true
        if let currentUser = dataManager.getCurrentUser()
        {
            isHidden = !currentUser.onStoryMode
            loadScreen(screen: scenario.map[currentUser.storyId]!)
        }
        else
        {
            //Can't load the current user
            print("StoryView : Can't load the current user to get storyView informations.")
            isHidden=true
        }
    }
    func loadScreen(screen : StoryScreen)
    {
        guard isSetted else
        {
            print("Trying to load a screen when the class is not setted is impossible")
            return
        }
        //Delete the previous screen
        deleteScreen()
        //Set the informations
        storyText.text = screen.text
        arrowButton.isHidden = !screen.nextButton
        arrowButton.action = screen.nextButtonAction
        
        //Set the buttons
        if screen.dataList.count > 0
        {
            let optimizedWidth = (buttonsArea.frame.width-16)/CGFloat(screen.dataList.count)-16
            let optimizedHeigth = buttonsArea.frame.height-16-8
            for (index,element) in screen.dataList.enumerated()
            {
                let newButton = StoryButton(frame : CGRect(x: 8+CGFloat(index)*(optimizedWidth+8),
                                                           y: 8,
                                                           width: optimizedWidth,
                                                           height: optimizedHeigth))
                newButton.load(data: element)
                newButton.addTarget(self, action: #selector(buttonPress), for: .touchUpInside)
                buttonsArea.addSubview(newButton)
                buttonsArea.bringSubview(toFront: newButton)
                
            }
        }
        else
        {
            //View shifting if no buttons
            storyText.frame = CGRect(x: 0, y: frame.height-storyText.frame.height, width: storyText.frame.width, height: storyText.frame.height)
            arrowButton.frame = CGRect(x: arrowButton.frame.origin.x, y: arrowButton.frame.origin.y + frame.height-storyText.frame.height, width: arrowButton.frame.width, height: arrowButton.frame.height)
        }
        
    }
    func deleteScreen()
    {
        storyText.text = ""
        buttonsArea.subviews.forEach({ $0.removeFromSuperview()})
        storyText.frame = rectLabel!
        arrowButton.frame = rectArrow!
    }
    @objc func buttonPress(sender : StoryButton)
    {
        delegate.storyPressButton(sender: sender)
    }
    
}

