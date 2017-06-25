//
//  Eboticon.swift
//  Eboticon1.2
//
//  Created by Troy Nunnally on 6/24/17.
//  Copyright © 2017 Incling. All rights reserved.
//

import Foundation


/* --------
 
 Our model for MVC
 keeps data  and calculations
 about Eboticon Object

 ------------*/

class Eboticon
{
    var id : Int = 52
    var gif : String = "https://s3.amazonaws.com/eboticon/happy_new_year_boo_B1-caption.gif"
    var still : String = "https://s3.amazonaws.com/eboticon/happy_new_year_boo_B1-caption.png"
    var name : String = "happy New Year Boo"
    var caption : String = "Caption"
    var movie : String = "https://s3.amazonaws.com/eboticon/happy_new_year_boo_B1-caption.mov"
    var category : String = "greeting"
    var skin_tone : String = "black"
    var status : String = "draft"
    var priority: Int = 1000
    
    //Declarations for Purchase Eboticons
    var isPurchased = false
    var pack: String = "com.eboticon.Eboticon.baepack1"
}



