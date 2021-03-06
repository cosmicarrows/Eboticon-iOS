//
//  Helper.swift
//  Eboticon1.2
//
//  Created by Johnson Ejezie on 28/06/2017.
//  Copyright © 2017 Incling. All rights reserved.
//

import UIKit

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

let baePackSectionHeaderImage = "BaePackSectionHeader"
let churchPackSectionHeaderImage = "ChurchPackSectionHeader"
let greekPackSectionHeaderImage = "GreekPackSectionHeader"
let greetingPackSectionHeaderImage = "GreetingPackSectionHeader"
let ratchetPackSectionHeaderImage = "RatchPackSectionHeader"
let publishedEndpoint = "eboticons/published"

@objc class Helper: NSObject {
    
    class func getEboticons(_ endpoint:String, completion:@escaping (([EboticonGif]?) -> ())) {
        let webservice = Webservice()
        let cachedWebservice = CachedWebservice(webservice)
        cachedWebservice.load(Helper.resource(URL(string:kBaseURL+endpoint)!)) { (result) in
            print("cachedWebservice")
            completion(result.value)
        }
    }
    
    class func getEboticonsFromServer(_ endpoint:String, completion:@escaping (([EboticonGif]?) -> ())) {
        let webservice = Webservice()
        let cachedWebservice = CachedWebservice(webservice)
        cachedWebservice.loadWithoutCheckingCache(Helper.resource(URL(string:kBaseURL+endpoint)!)) { (result) in
            print("cachedWebservice")
            completion(result.value)
        }
    }
    
    class func resource(_ url:URL) -> Resource<[EboticonGif]> {
        return Resource<[EboticonGif]>(url: url) { (json) -> [EboticonGif]? in
            var eboticons = [EboticonGif]()
            if let jsonArray = json as? [JSONDictionary] {
                for eboticonDict in jsonArray {
                    let id = eboticonDict["id"] as? NSNumber ?? 0
                    let gif = eboticonDict["gif"] as? String ?? ""
                    let still = eboticonDict["still"] as? String ?? ""
                    let name = eboticonDict["name"] as? String ?? ""
                    let caption = eboticonDict["caption"] as? String ?? ""
                    let mov = eboticonDict["movie"] as? String ?? ""
                    let category = eboticonDict["category"] as? String ?? ""
                    let skinTone = eboticonDict["skin_tone"] as? String ?? ""
                    let pack = eboticonDict["pack"] as? String ?? ""
                    
                    let eboticon = EboticonGif(attributes: name, gifURL: gif, captionCategory: caption, category: category, eboticonID: id, movieURL: mov, stillURL: still, skinTone: skinTone, displayType: "", purchaseCategory: pack)
                    guard let unwrappedEboticon = eboticon else {
                        continue
                    }
                    eboticons.append(unwrappedEboticon)
                }
            }
            return eboticons
        }
    }
    
    
    class func packSectionHeaderImage(_ eboticon:EboticonGif) -> UIImage? {
        if Helper.isBaePack(eboticon) {
            return UIImage(named: baePackSectionHeaderImage)
        }
        if Helper.isChurchPack(eboticon) {
            return UIImage(named: churchPackSectionHeaderImage)
        }
        if Helper.isGreekPack(eboticon) {
            return UIImage(named: greekPackSectionHeaderImage)
        }
        if Helper.isGreetingPack(eboticon) {
            return UIImage(named: greetingPackSectionHeaderImage)
        }
        if Helper.isRatchetPack(eboticon) {
            return UIImage(named: ratchetPackSectionHeaderImage)
        }
        return nil
    }
    
    class func topViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }
        
        guard let presented = rootViewController.presentedViewController else {
            return rootViewController
        }
        
        switch presented {
        case let navigationController as UINavigationController:
            return topViewController(navigationController.viewControllers.last)
            
        case let tabBarController as UITabBarController:
            return topViewController(tabBarController.selectedViewController)
            
        default:
            return topViewController(presented)
        }
    }
    
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

//extension Sequence where Iterator.Element: Hashable {
//    func unique() -> [Iterator.Element] {
//        var seen = Set<Iterator.Element>()
//        return filter { seen.update(with: $0) == nil }
//    }
//}
//func == (lhs: EboticonGif, rhs: EboticonGif) -> Bool {
//    return lhs.eboticonID == rhs.eboticonID
//}
