//
//  menuSectionCell.swift
//  LittleFarm
//
//  Created by saad on 22/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit
class menuSection : UIView
{
    @IBOutlet var contentView : UIView!
    @IBOutlet var imageLeft : UIImageView!
    @IBOutlet var imageRight : UIImageView!
    @IBOutlet var textLabel : UILabel!
    
    /*
    @IBInspectable var image : UIImage?
        {
        get {
            return imageLeft.image
        }
        set(image)
        {
            imageLeft.image = image
            imageRight.image = image
        }
    }
    @IBInspectable var message : String?
        {
        get {
            return textLabel.text
        }
        set(message) {
            textLabel.text = message
        }
    }
 */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    func xibSetup()
    {
        //contentView = loadViewFromNib()
        
        Bundle.main.loadNibNamed("menuSection", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
    }
    func loadSection(imagePath : String,text : String)
    {
        imageLeft.image = UIImage(named: imagePath)
        imageRight.image = UIImage(named: imagePath)
        textLabel.text = text
        textLabel.textColor=UIColorSet.ligthOrange
        textLabel.font = UIFont(name : "Century Gothic", size : 20)
    }
    
    func loadViewFromNib() -> UIView
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing : type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
}

