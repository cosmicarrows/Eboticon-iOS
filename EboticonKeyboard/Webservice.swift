//
//  Webservice.swift
//  Eboticon1.2
//
//  Created by Johnson Ejezie on 25/03/2017.
//  Copyright © 2017 Incling. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]
let kBaseURL = "https://api.eboticons.com/v1/"


@objc class Webservice:NSObject {
    
    func loadEboticons(endpoint: String, onlyFreeOnce:Bool, completion: @escaping ([EboticonGif]?) -> ()) {
        guard let url = URL(string:kBaseURL+endpoint) else {
            return
        }        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else {
                completion(nil)
                return
            }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let jsonArray = json as? [JSONDictionary] {
                var eboticons = [EboticonGif]()
                for eboticonDict in jsonArray {
                    let pack = eboticonDict["pack"] as? String ?? ""
                    if onlyFreeOnce {
                        if pack != "" {
                            continue
                        }
                    }
                    let id = eboticonDict["id"] as? NSNumber ?? 0
                    let gif = eboticonDict["gif"] as? String ?? ""
                    let still = eboticonDict["still"] as? String ?? ""
                    let name = eboticonDict["name"] as? String ?? ""
                    let caption = eboticonDict["caption"] as? String ?? ""
                    let mov = eboticonDict["movie"] as? String ?? ""
                    let category = eboticonDict["category"] as? String ?? ""
                    let skinTone = eboticonDict["skin_tone"] as? String ?? ""
                    
                    
                    let eboticon = EboticonGif(attributes: name, gifURL: gif, captionCategory: caption, category: category, eboticonID: id, movieURL: mov, stillURL: still, skinTone: skinTone, displayType: "", purchaseCategory: pack)
                    guard let unwrappedEboticon = eboticon else {
                        continue
                    }
                    eboticons.append(unwrappedEboticon)
                }
                completion(eboticons)
                
            }
            }.resume()
    }
}

let baePack = "com.eboticon.Eboticon.baepack"
let churchPack = "com.eboticon.Eboticon.churchpack"
let greekPack = "com.eboticon.Eboticon.greekpack"  // com.eboticon.Eboticon.greekpack1
let greetingPack = "com.eboticon.Eboticon.greetingspack"
let ratchetPack = "com.eboticon.Eboticon.ratchpack"

let caption = "Caption"

let love = "love"
let happy = "happy"
let unhappy = "not_happy"
let greeting = "greeting"
let exclamation = "exclamation"

@objc class KeyboardHelper:NSObject {
    class func isBaePack(_ eboticon:EboticonGif) -> Bool {
        if eboticon.purchaseCategory == "" {
            return false
        }
        let pack = eboticon.purchaseCategory.substring(to: eboticon.purchaseCategory.index(before: eboticon.purchaseCategory.endIndex))
        return pack == baePack
    }
    class func isChurchPack(_ eboticon:EboticonGif) -> Bool {
        if eboticon.purchaseCategory == "" {
            return false
        }
        let pack = eboticon.purchaseCategory.substring(to: eboticon.purchaseCategory.index(before: eboticon.purchaseCategory.endIndex))
        return pack == churchPack
    }
    class func isGreekPack(_ eboticon:EboticonGif) -> Bool {
        if eboticon.purchaseCategory == "" {
            return false
        }
        let pack = eboticon.purchaseCategory.substring(to: eboticon.purchaseCategory.index(before: eboticon.purchaseCategory.endIndex))
        return pack == greekPack
    }
    class func isGreetingPack(_ eboticon:EboticonGif) -> Bool {
        if eboticon.purchaseCategory == "" {
            return false
        }
        let pack = eboticon.purchaseCategory.substring(to: eboticon.purchaseCategory.index(before: eboticon.purchaseCategory.endIndex))
        return pack == greetingPack
    }
    class func isRatchetPack(_ eboticon:EboticonGif) -> Bool {
        if eboticon.purchaseCategory == "" {
            return false
        }
        let pack = eboticon.purchaseCategory.substring(to: eboticon.purchaseCategory.index(before: eboticon.purchaseCategory.endIndex))
        return pack == ratchetPack
    }
    class func isFreePack(_ eboticon:EboticonGif) -> Bool {
        return eboticon.purchaseCategory == ""
    }
    class func isCaption(_ eboticon:EboticonGif) -> Bool {
        return eboticon.category == caption
    }
    
    class func isLove(_ eboticon:EboticonGif) -> Bool {
        return eboticon.emotionCategory == love
    }
    class func isHappy(_ eboticon:EboticonGif) -> Bool {
        return eboticon.emotionCategory == happy
    }
    class func isUnhappy(_ eboticon:EboticonGif) -> Bool {
        return eboticon.emotionCategory == unhappy
    }
    class func isGreeting(_ eboticon:EboticonGif) -> Bool {
        return eboticon.emotionCategory == greeting
    }
    class func isExclamation(_ eboticon:EboticonGif) -> Bool {
        return eboticon.emotionCategory == exclamation
    }

}


