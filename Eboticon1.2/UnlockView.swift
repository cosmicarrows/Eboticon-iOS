//
//  UnlockView.swift
//  Eboticon1.2
//
//  Created by Johnson Ejezie on 23/05/2017.
//  Copyright © 2017 Incling. All rights reserved.
//

import UIKit

class UnlockView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var unlockButton: UIButton!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var packImageView: UIImageView!
    @IBOutlet var closeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        unlockButton.layer.cornerRadius = 5
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("UnlockView", owner: self, options: nil)
        self.addSubview(contentView)
        self.contentView.frame = self.bounds
    }

    @IBAction func unlockButtonTapped(_ sender: Any) {
    }
    @IBAction func closeButtonTapped(_ sender: Any) {
    }
}
