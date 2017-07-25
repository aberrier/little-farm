//
//  RegisterViewController.swift
//  LittleFarm
//
//  Created by saad on 20/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class RegisterViewController : UIViewController,UIPickerViewDelegate,UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource
{
    
    
    
    
    var productId : String = ""
    
    @IBOutlet var textLabel : niceLabel!
    @IBOutlet var image : UIImageView!
    @IBOutlet var nextButton : UIButton!
    
    @IBOutlet var registerForm : UIView!
    @IBOutlet var surnameField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var nameField : UITextField!
    @IBOutlet var datePicker : UIDatePicker!
    @IBOutlet var emailField : UITextField!
    @IBOutlet var genderPicker : UIPickerView!
    @IBOutlet var imagePicker : UICollectionView!
    @IBOutlet var validateButton : UIButton!
    
    //Variables relative to imagePicker
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    
    //Don't forget to add a new text field on checkForEmptyField
    
    let dataManager = PersistentDataManager.sharedInstance
    
    var genderSelected : Int16 = 1
    var imageSelected : String = "default"
    var sequence : Int = 0
    
    var newUser : UserData = UserData()
    var genderPickerData = ["Je suis un garçon !","Je suis une fille !"]
    var imagePickerData = ["girl-1","girl-2","boy-1","boy-2","robot","alien"]
    override func viewDidLoad() {
        
        //Label settings
        view.layoutIfNeeded()
        //Register initialization
        datePicker.maximumDate = Date.init(timeIntervalSinceNow: 0)
        genderPicker.delegate = self
        genderPicker.dataSource = self
        imagePicker.delegate = self
        imagePicker.dataSource = self
        
        updateSequence()
        
    }
    
    //genderPicker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderPickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderPickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderSelected = Int16(row)
    }
    
    //imagePicker
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePickerData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let newCell = imagePicker.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imagePickerCell
        
        newCell.imageView.image = UIImage(named: imagePickerData[indexPath.row])
        return newCell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageSelected = imagePickerData[indexPath.row]
        for cell in imagePicker.visibleCells
        {
            cell.layer.backgroundColor = UIColor.white.cgColor
        }
        imagePicker.cellForItem(at: indexPath)?.layer.backgroundColor=UIColorSet.darkBlue.cgColor
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * CGFloat(imagePickerData.count + 2)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(imagePickerData.count)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    //***
    func checkForEmptyField() -> Bool
    {
        let fieldList : [UITextField] = [nameField,surnameField,emailField,passwordField]
        var thereIsAEmptyField : Bool = false
        for field in fieldList
        {
            if field.text == nil
            {
                field.layer.borderColor = UIColorSet.red.cgColor
                field.layer.borderWidth = 1
                thereIsAEmptyField = true
            }
            else if field.text == ""
            {
                field.layer.borderColor = UIColorSet.red.cgColor
                field.layer.borderWidth = 1
                thereIsAEmptyField = true
                
            }
            else
            {
                field.layer.borderWidth = 0
            }
        }
        return thereIsAEmptyField
    }
    func showRegisterForm(_ trigger : Bool)
    {
        if(!trigger)
        {
            registerForm.isHidden = true
            nextButton.isHidden = false
            textLabel.isHidden = false
            nextButton.isHidden = false
        }
        else
        {
            registerForm.isHidden = false
            nextButton.isHidden = true
            textLabel.isHidden = true
            nextButton.isHidden = true
        }
        
    }
    func updateSequence()
    {
        switch(sequence)
        {
            
        case 0 :
            showRegisterForm(false)
            textLabel.numberOfLines = 2
            textLabel.text = "Tiens tiens...\nOn dirait qu'il y a quelqu'un là dedans"
            image.image = UIImage(named: "egg-2")
        case 1 :
            showRegisterForm(false)
            textLabel.numberOfLines = 2
            textLabel.text = "Bravo !\nVous venez d'adopter un petit wip !"
            image.image = UIImage(named:  "egg-3")
        case 2 :
            showRegisterForm(false)
            textLabel.numberOfLines = 2
            textLabel.text = "Oh!\npetit wip vient de se cacher.."
            image.image = UIImage(named:  "egg-1")
        case 3 :
            showRegisterForm(false)
            textLabel.numberOfLines = 1
            textLabel.text = "Nous vous inquiétez pas, les wips sont connus pour être craintifs face aux inconnus.."
            image.image = UIImage(named:  "egg-1")
        case 4 :
            showRegisterForm(false)
            textLabel.numberOfLines = 2
            textLabel.text = "Il faut d'abord le rassurer.\nCommencez par vous présenter."
            image.image = UIImage(named:  "egg-1")
            //add button
        case 5 :
            showRegisterForm(true)
            //special sequence : register form
        case 6 :
            showRegisterForm(false)
            textLabel.numberOfLines = 2
            textLabel.text = "Ah ! le voilà qu'il sort de sa cachette.\nPromettez-vous à petit wip de prendre soin de lui ?"
            image.image = UIImage(named:  "egg-3")
        case 7 :
            QRCodeQuery()
        default : break
        }
    }
    
    @IBAction func moveToNextSequence(sender : UIButton)
    {
        switch(sequence)
        {
        case 0,1,2,3,4,6:
            sequence+=1
            updateSequence()
        case 5:
            print("ok")
            if sender == validateButton && !checkForEmptyField()
            {
                print("oui")
                newUser.name = nameField.text!
                newUser.surname = surnameField.text!
                newUser.birthDate = datePicker.date
                newUser.email = emailField.text!
                newUser.gender = genderSelected
                newUser.id = dataManager.getNewId()
                newUser.password = passwordField.text!
                newUser.image = imageSelected
                dataManager.addUser(newUser: newUser)
                sequence+=1
                updateSequence()
            }
            
        default: break
        }
    }
   func QRCodeQuery()
    {
        let storyboard = UIStoryboard(name : "Main", bundle : nil)
        
        let QRCodeView = storyboard.instantiateViewController(withIdentifier: "QRCodeView") as! QRCodeViewController
        QRCodeView.nextController = .ARViewController
        
        self.present(QRCodeView, animated: true, completion: nil)
    }
}
