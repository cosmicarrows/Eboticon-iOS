//
//  PackHeaderCollectionReusableView.swift
//  Eboticon1.2
//
//  Created by Johnson Ejezie on 02/07/2017.
//  Copyright © 2017 Incling. All rights reserved.
//

import UIKit

class PackHeaderCollectionReusableView: UICollectionReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static let kIdentifier = "PackHeaderCollectionReusableView"
    
    @IBOutlet var sectionHeaderImageView: UIImageView!
    
    var eboticon:EboticonGif! {
        didSet {
            sectionHeaderImageView.image = Helper.packSectionHeaderImage(eboticon)
        }
    }
    
}
