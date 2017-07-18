//
//  KouriKeyPad.swift
//  Eboticon1.2
//
//  Created by Johnson Ejezie on 18/07/2017.
//  Copyright © 2017 Incling. All rights reserved.
//

import UIKit

let kCatTypeEnabled = "kCatTypeEnabled"

class Catboard: KVKeyboardViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        UserDefaults.standard.register(defaults: [kCatTypeEnabled: true])
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyPressed(_ key: Key) {
        let textDocumentProxy = self.textDocumentProxy
        
        let keyOutput = key.outputForCase(self.shiftState.uppercase())
        
        if !UserDefaults.standard.bool(forKey: kCatTypeEnabled) {
            InsertText(keyOutput)
            return
        }
        
        if key.type == .character || key.type == .specialCharacter {
            let context = textDocumentProxy.documentContextBeforeInput
            if context != nil {
                if context!.characters.count < 2 {
                    InsertText(keyOutput)
                    return
                }
                
                var index = context!.endIndex
                
                index = context!.index( before: index )
                if context?.characters[index] != " " {
                    InsertText(keyOutput)
                    return
                }
                
                index = context!.index( before: index )
                if context?.characters[index] == " " {
                    InsertText(keyOutput)
                    return
                }
                
                InsertText(keyOutput)
                return
            }
            else {
                InsertText(keyOutput)
                return
            }
        }
        else {
            InsertText(keyOutput)
            return
        }
        
    }
    
    override func setupKeys() {
        super.setupKeys()
    }
    
    override func createBanner() -> SuggestionView {
        return CatboardBanner(darkMode: false, solidColorMode: self.solidColorMode())
    }
    
}
