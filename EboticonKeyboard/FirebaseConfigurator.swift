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
        FIRApp.configure()
        
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
            kFIRParameterItemID: "id-\(title)" as NSObject,
            kFIRParameterItemName: title as NSObject,
            kFIRParameterContentType: "cont" as NSObject
            ]);
        
    }
}

    
