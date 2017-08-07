//
//  RegisterViewController.swift
//  LittleFarm
//
//  Created by saad on 20/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class RegisterViewController : UIViewController,UIPickerViewDelegate,UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate
{
    
    
    
    let dataManager = PersistentDataManager.sharedInstance
    
    var productId : String = ""
    
    //Scenario variables
    @IBOutlet var textLabel : LFLabel!
    @IBOutlet var image : UIImageView!
    @IBOutlet var nextButton : UIButton!
    
    //Register outlets
    @IBOutlet var registerForm : UIView!
    @IBOutlet var surnameField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var nameField : UITextField!
    @IBOutlet var datePicker : UIDatePicker!
    @IBOutlet var emailField : UITextField!
    @IBOutlet var genderPicker : UIPickerView!
    @IBOutlet var imagePicker : UICollectionView!
    @IBOutlet var validateButton : UIButton!
    
    //Register variables
    var genderSelected : Int16 = 1
    var imageSelected : String = generalInformations.defaultImage
    var sequence : Int = 0
    var newUser : UserData = UserData()
    var genderPickerData = generalInformations.registerGenderTab
    var imagePickerData = generalInformations.registerImageTab
    let scenario = RegisterScenario.instance
    
    //Variables relative to imagePicker
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    
    //Don't forget to add a new text field on checkForEmptyField
    
    override func viewDidLoad() {
        
        
        //Label settings
        view.layoutIfNeeded()
        
        //Register initialization
        datePicker.maximumDate = Date.init(timeIntervalSinceNow: 0)
        genderPicker.delegate = self
        genderPicker.dataSource = self
        imagePicker.delegate = self
        imagePicker.dataSource = self
        view.addGestureRecognizer(UITapGestureRecognizer(target : self,action : #selector(dismissKeyboard)))
        updateSequence()
        
    }
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
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
    
    
    //Check for empty fields
    func checkForEmptyField() -> Bool
    {
        let fieldList : [UITextField] = [nameField,surnameField,emailField,passwordField]
        var thereIsAEmptyField : Bool = false
        for field in fieldList
        {
            if field.text == nil
            {
                field.layer.borderColor = UIColorSet.red.cgColor
                field.layer.borderWidth = 2
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
        registerForm.isHidden = !trigger
        nextButton.isHidden = trigger
        textLabel.isHidden = trigger
        nextButton.isHidden = trigger
    }
    //Update the sequence with the scenario
    func updateSequence()
    {
        
        guard sequence <= scenario.tab.count else
        {
            print("Register - updateSequence : Sequence value higher than number of screens.")
            return
        }
        
        let currentScreen = scenario.tab[sequence]
        
        if currentScreen.end
        {
            callQRCodeController()
        }
        else
        {
            showRegisterForm(currentScreen.registerForm)
            textLabel.numberOfLines = currentScreen.numberOfLines
            textLabel.text = currentScreen.text
            image.image = UIImage(named: currentScreen.image)
        }
    }
    
    @IBAction func moveToNextSequence(sender : UIButton)
    {
        guard sequence <= scenario.tab.count else
        {
            print("Register - moveToNextSequence : Sequence value higher than number of screens.")
            return
        }
        
        let currentScreen = scenario.tab[sequence]
        
        if currentScreen.registerForm
        {
            if sender == validateButton && !checkForEmptyField()
            {
                createNewUser()
                sequence+=1
                updateSequence()
            }
            else
            {
                view.layer.add(GT.giveShakeAnimation(), forKey: nil)
            }
            
        }
        else
        {
            sequence+=1
            updateSequence()
        }
        
        
    }
    func createNewUser()
    {
        //Creation of a new user
        newUser.name = nameField.text!
        newUser.surname = surnameField.text!
        newUser.birthDate = datePicker.date
        newUser.email = emailField.text!
        newUser.gender = genderSelected
        newUser.id = dataManager.getNewId()
        newUser.password = passwordField.text!
        newUser.image = imageSelected
        newUser.onStoryMode = true
        newUser.storyId = generalInformations.firstStoryId
        
        dataManager.addUser(newUser: newUser)
        dataManager.setConnectedUser(userId: newUser.id)
        
    }
    func callQRCodeController()
    {
        let storyboard = UIStoryboard(name : "Main", bundle : nil)
        
        let QRCodeView = storyboard.instantiateViewController(withIdentifier: "QRCodeView") as! QRCodeViewController
        QRCodeView.nextController = .ARViewController
        
        self.present(QRCodeView, animated: true, completion: nil)
    }
}


