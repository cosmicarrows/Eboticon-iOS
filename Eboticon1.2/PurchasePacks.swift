//
//  PurchasePacks.swift
//  Eboticon1.2
//
//  Created by Troy Nunnally on 6/24/17.
//  Copyright © 2017 Incling. All rights reserved.
//

import Foundation


/* --------
 
 Purchase Packs Object
 
 ------------*/

// MARK: - Purchase Packs Singleton

// The final keyword ensures our singleton cannot be subclassed.
// private init prevents other objects from creating their own instances of the singleton class
final class PurchasePacks {
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    
    static let shared = PurchasePacks()
    
    // MARK: Local Variable
    var list : [PurchasePack] = []
}


