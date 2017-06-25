//
//  Eboticons.swift
//  Eboticon1.2
//
//  Created by Troy Nunnally on 6/24/17.
//  Copyright © 2017 Incling. All rights reserved.
//

import Foundation


/* --------
 
 Eboticons Object
 
 ------------*/

// MARK: - Eboticons Singleton

// The final keyword ensures our singleton cannot be subclassed.
// private init prevents other objects from creating their own instances of the singleton class
final class Eboticons {
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    
    static let shared = Eboticons()
    
    // MARK: Local Variable
    var list : [Eboticon] = []
}

