//
//  FirebaseConfigurator.swift
//  Eboticon1.2
//
//  Created by Troy Nunnally on 2/22/17.
//  Copyright © 2017 Incling. All rights reserved.
//

import Foundation

import Firebase

// Singleton Class
@objc class FirebaseConfigurator: NSObject {
    var strSample = NSString()
    
    static let sharedInstance:FirebaseConfigurator = {
        let instance = FirebaseConfigurator ()
        return instance
    }()
    
    // MARK: Init
    override init() {
        super.init()
        if (isOpenAccessGranted()){
            FIRApp.configure()
        }
        
        print("My Class Initialized")
        // initialized with variable or property
        strSample = "My String"
    }
    
    func test () -> String {
        return "Swift says hi!"
    }
    
    func logEvent (_ title: String) -> () {
        
        print("---logEvent---");
        print(title);
        
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterItemID: "\(title)" as NSObject,
            kFIRParameterItemName: title as NSObject,
            kFIRParameterContentType: "content" as NSObject
            ]);
        
    }
    
    func isOpenAccessGranted() -> Bool {
        
        if #available(iOSApplicationExtension 10.0, *) {
            UIPasteboard.general.string = "TEST"
            
            if UIPasteboard.general.hasStrings {
                // Enable string-related control...
                UIPasteboard.general.string = ""
                return  true
            }
            else
            {
                UIPasteboard.general.string = ""
                return  false
            }
        } else {
            // Fallback on earlier versions
            if UIPasteboard.general.isKind(of: UIPasteboard.self) {
                return true
            }else
            {
                return false
            }
            
        }
        
    }
}

    
