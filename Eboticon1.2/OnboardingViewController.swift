//
//  OnboardingViewController.swift
//  Eboticon1.2
//
//  Created by Troy Nunnally on 4/17/17.
//  Copyright © 2017 Incling. All rights reserved.
//

import Foundation



@objc class OnboardingViewController:UIViewController {
    

    @IBOutlet var girlImageView: UIImageView!
    @IBOutlet var boyImageView: UIImageView!
    
    @IBOutlet var confirmButton: UIButton!
    
    @IBOutlet var asianButton: UIButton!
    @IBOutlet var whiteButton: UIButton!
    @IBOutlet var blackButton: UIButton!
    
    var isBlackSelected: Bool! = true
    var isWhiteSelected: Bool! = false
    var isAsianSelected: Bool! = false
    
    override func viewDidLoad(){
        
        let skintone = UserDefaults.standard.string(forKey:"skin_tone")

        
        if skintone == "asian" {
            //Set State
            self.isAsianSelected = true
            self.isWhiteSelected = false
            self.isBlackSelected = false
        }
        
        if skintone == "white" {
            //Set State
            self.isAsianSelected = false
            self.isWhiteSelected = true
            self.isBlackSelected = false
        }
        
        if skintone == "black" {
            //Set State
            self.isAsianSelected = false
            self.isWhiteSelected = false
            self.isBlackSelected = true
        }
        
 
        
        changedSkinTone()
        
        
    }
    
    func changedSkinTone(){
        
        if self.isAsianSelected==true {
            //Set Button State
            asianButton.setImage(UIImage(named:"OnboardingButtonAsianHL"), for: UIControlState.normal)
            blackButton.setImage(UIImage(named:"OnboardingButtonBlack"), for: UIControlState.normal)
            whiteButton.setImage(UIImage(named:"OnboardingButtonWhite"), for: UIControlState.normal)
            
            
            //Switch Selection Images
            girlImageView.image = UIImage(named: "OnboardingSelectionAsianGirl")
            boyImageView.image = UIImage(named: "OnboardingSelectionAsianBoy")
            
            UserDefaults.standard.set("asian", forKey: "skin_tone") //setObject
            
            
        }
        
        if self.isWhiteSelected==true {
            //Set Button State
            asianButton.setImage(UIImage(named:"OnboardingButtonAsian"), for: UIControlState.normal)
            blackButton.setImage(UIImage(named:"OnboardingButtonBlack"), for: UIControlState.normal)
            whiteButton.setImage(UIImage(named:"OnboardingButtonWhiteHL"), for: UIControlState.normal)
            
            //Switch Selection Images
            girlImageView.image = UIImage(named: "OnboardingSelectionWhiteGirl")
            boyImageView.image = UIImage(named: "OnboardingSelectionWhiteBoy")
            
            //To save the string
            UserDefaults.standard.set("white", forKey: "skin_tone") //setObject
        }
        
        if self.isBlackSelected==true {
            
            //Set Button State
            asianButton.setImage(UIImage(named:"OnboardingButtonAsian"), for: UIControlState.normal)
            blackButton.setImage(UIImage(named:"OnboardingButtonBlackHL"), for: UIControlState.normal)
            whiteButton.setImage(UIImage(named:"OnboardingButtonWhite"), for: UIControlState.normal)
            
            //Switch Selection Images
            girlImageView.image = UIImage(named: "OnboardingSelectionBlackGirl")
            boyImageView.image = UIImage(named: "OnboardingSelectionBlackBoy")
            
            //To save the string
            UserDefaults.standard.set("black", forKey: "skin_tone") //setObject
        }
        
    }

    @IBAction func tappedConfirmButton(_ sender: Any){
        
        print(UserDefaults.standard.string(forKey:"skin_tone")!)
        
        //Load shared instance
        if let mainViewController = MainViewController.sharedInstance() {
            mainViewController.savedSkinTone = UserDefaults.standard.string(forKey:"skin_tone")
           // mainViewController.loadEboticon()
        }
        
        //Set User Default if confirned for the first time.
        if UserDefaults.standard.string(forKey:"app_open") != "true" {
            UserDefaults.standard.set("true", forKey: "app_open")
        }
        
        // Define identifier
        let notificationName = Notification.Name("reloadEboticons")
        NotificationCenter.default.post(name:notificationName, object: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func tappedAsian(_ sender: Any) {

        //Set State
        isAsianSelected = true
        isWhiteSelected = false
        isBlackSelected = false
        
        changedSkinTone()
        
        
    }
    
    
    @IBAction func tappedWhite(_ sender: Any) {


        //Set State
        isAsianSelected = false
        isWhiteSelected = true
        isBlackSelected = false
        
        changedSkinTone()

    }
    
    
    @IBAction func tappedBlack(_ sender: Any) {

        //Set State
        isAsianSelected = false
        isWhiteSelected = false
        isBlackSelected = true
        
        changedSkinTone()

    }

}
