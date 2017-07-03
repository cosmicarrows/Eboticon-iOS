//
//  Webservice.swift
//  Eboticon1.2
//
//  Created by Johnson Ejezie on 25/03/2017.
//  Copyright © 2017 Incling. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]
let kBaseURL = "http://api.eboticons.com/v1/"


@objc class Webservice:NSObject, URLSessionDelegate {
    
    func loadEboticons(endpoint: String, completion: @escaping ([JSONDictionary]?) -> ()) {
        guard let url = URL(string:kBaseURL+endpoint) else {
            return
        }
        let configuration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        session.dataTask(with: url) { data, response, error in

            guard let data = data else {
                completion(nil)
                return
            }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let jsonArray = json as? [JSONDictionary] {
                completion(jsonArray)
            }
            }.resume()
    }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        
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


