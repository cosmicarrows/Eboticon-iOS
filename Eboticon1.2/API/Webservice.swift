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
    
    static func loadEboticons(endpoint: String, completion: @escaping ([EboticonGif]?) -> ()) {
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
                completion(eboticons)
            }
            }.resume()
    }
    
    static func loadPacks(endpoint: String, completion: @escaping ([PurchasePacks]?) -> ()) {
        
    }
    
    
    
    

}


