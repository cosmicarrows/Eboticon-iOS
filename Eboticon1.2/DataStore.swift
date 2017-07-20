//
//  dataStore.swift
//  Eboticon1.2
//
//  Created by Johnson Ejezie on 01/07/2017.
//  Copyright © 2017 Incling. All rights reserved.
//

import Foundation

@objc final class DataStore: NSObject {
    
    // Can't init is singleton
    private override init() { }
    
    // MARK: Shared Instance
    
    static let shared = DataStore()
    
    // MARK: Local Variable
    // array of form [[free pack eboticon], [bae pack], [church pack], [greek pack], [greeting pack], [ratch pack]]
    var freePack: [EboticonGif] = []
    var baePack: [EboticonGif] = []
    
    var churchPack: [EboticonGif] = []
    var greekPack: [EboticonGif] = []
    
    var greetingPack: [EboticonGif] = []
    var ratchetPack: [EboticonGif] = []
    var all: [EboticonGif] = []
        
    func setupDataStore(_ eboticons:[EboticonGif], tone:String) {
        churchPack.removeAll()
        freePack.removeAll()
        baePack.removeAll()
        greekPack.removeAll()
        greetingPack.removeAll()
        ratchetPack.removeAll()
        var baePackSeen = Set<String>()
        var churchPackSeen = Set<String>()
        var greekPackSeen = Set<String>()
        var greetingPackSeen = Set<String>()
        var ratchetPackSeen = Set<String>()
        
        for eboticon in eboticons {
            if tone == eboticon.skinTone {
                if Helper.isFreePack(eboticon) {
                    freePack.append(eboticon)
                } else if Helper.isBaePack(eboticon) && !baePackSeen.contains(eboticon.stillUrl) {
                    baePack.append(eboticon)
                    baePackSeen.insert(eboticon.stillUrl)
                } else if Helper.isChurchPack(eboticon) && !churchPackSeen.contains(eboticon.stillUrl) {
                    churchPack.append(eboticon)
                    churchPackSeen.insert(eboticon.stillUrl)
                } else if Helper.isGreekPack(eboticon) && !greekPackSeen.contains(eboticon.stillUrl) {
                    greekPack.append(eboticon)
                    greekPackSeen.insert(eboticon.stillUrl)
                } else if Helper.isGreetingPack(eboticon) && !greetingPackSeen.contains(eboticon.stillUrl) {
                    greetingPack.append(eboticon)
                    greetingPackSeen.insert(eboticon.stillUrl)
                } else if Helper.isRatchetPack(eboticon) && !ratchetPackSeen.contains(eboticon.stillUrl) {
                    ratchetPack.append(eboticon)
                    ratchetPackSeen.insert(eboticon.stillUrl)
                }
                
            }
        }        
    }
    
    func hasData()->Bool {
        return !freePack.isEmpty || !baePack.isEmpty || !churchPack.isEmpty || !greekPack.isEmpty || !ratchetPack.isEmpty
    }
    
    public func fetchEboticons(_ caption:Bool, category:String) -> [[EboticonGif]] {
        var function:(EboticonGif) -> Bool = Helper.isLove(_:)
        switch category {
        case "Recent":
            return recent(caption)
        case "love":
            function = Helper.isLove(_:)
        case "happy":
            function = Helper.isHappy(_:)
        case "unhappy":
            function = Helper.isUnhappy(_:)
        case "greeting":
            function = Helper.isGreeting(_:)
        case "exclamation":
            function = Helper.isExclamation(_:)
        case "Purchased":
            return purchased(caption)
        default:
            return all(caption)
        }
        return arrangeDataBasedOn(caption, function: function)
    }
    
    //Figure out how to merge these 3 similar function
    
    func arrangeDataBasedOn(_ caption:Bool, function:(EboticonGif) -> Bool) -> [[EboticonGif]] {
        var all: [[EboticonGif]] = []
        if caption {
            all.append(freePack.filter{ Helper.isCaption($0) && function($0)})
            all.append(baePack.filter{ Helper.isCaption($0) && function($0)})
            all.append(churchPack.filter{ Helper.isCaption($0) && function($0)})
            all.append(greekPack.filter{ Helper.isCaption($0) && function($0)})
            all.append(greetingPack.filter{ Helper.isCaption($0) && function($0)})
            all.append(ratchetPack.filter{ Helper.isCaption($0) && function($0)})
        } else {
            all.append(freePack.filter{ !Helper.isCaption($0) && function($0)})
            all.append(baePack.filter{ !Helper.isCaption($0) && function($0)})
            all.append(churchPack.filter{ !Helper.isCaption($0) && function($0)})
            all.append(greetingPack.filter{ !Helper.isCaption($0) && function($0)})
            all.append(ratchetPack.filter{ !Helper.isCaption($0) && function($0)})
        }
        return all
    }
    private func recent(_ caption:Bool) -> [[EboticonGif]] {
        var all: [[EboticonGif]] = []
        let recentGif = UserDefaults.standard.object(forKey: "listOfRecentGifs") as? [String]
        guard let gifs = recentGif else { return all }
        var recentFreePack:[EboticonGif] = []
        var recentBaePack: [EboticonGif] = []
        
        var recentChurchPack: [EboticonGif] = []
        var recentGreekPack: [EboticonGif] = []
        
        var recentGreetingPack: [EboticonGif] = []
        var recentRatchetPack: [EboticonGif] = []
        for fileName in gifs {
            recentFreePack.append(contentsOf: freePack.filter{ $0.fileName == fileName && Helper.isCaption($0)})
            recentBaePack.append(contentsOf: baePack.filter{ $0.fileName == fileName && Helper.isCaption($0) })
            recentChurchPack.append(contentsOf: churchPack.filter{ $0.fileName == fileName && Helper.isCaption($0) })
            recentGreekPack.append(contentsOf: greekPack.filter{ $0.fileName == fileName && Helper.isCaption($0) })
            recentGreetingPack.append(contentsOf: greetingPack.filter{ $0.fileName == fileName && Helper.isCaption($0) })
            recentRatchetPack.append(contentsOf: ratchetPack.filter{ $0.fileName == fileName && Helper.isCaption($0) })
        }
        all.append(recentFreePack)
        all.append(recentBaePack)
        all.append(recentChurchPack)
        all.append(recentGreekPack)
        all.append(recentGreetingPack)
        all.append(recentRatchetPack)
        return all
    }
    private func purchased(_ caption:Bool) -> [[EboticonGif]] {
        var all: [[EboticonGif]] = []
            all.append(baePack.filter{ Helper.isCaption($0) })
            all.append(churchPack.filter{ Helper.isCaption($0) })
            all.append(greekPack.filter{ Helper.isCaption($0) })
            all.append(greetingPack.filter{ Helper.isCaption($0) })
            all.append(ratchetPack.filter{ Helper.isCaption($0) })
        return all
    }
    
    private func all(_ caption:Bool) -> [[EboticonGif]] {
        var all: [[EboticonGif]] = []
        if caption {
            all.append(freePack.filter{ Helper.isCaption($0) })
            all.append(baePack.filter{ Helper.isCaption($0) })
            all.append(churchPack.filter{ Helper.isCaption($0) })
            all.append(greekPack.filter{ Helper.isCaption($0) })
            all.append(greetingPack.filter{ Helper.isCaption($0) })
            all.append(ratchetPack.filter{ Helper.isCaption($0) })
        } else {
            all.append(freePack.filter{ !Helper.isCaption($0) })
            all.append(baePack.filter{ !Helper.isCaption($0) })
            all.append(churchPack.filter{ !Helper.isCaption($0) })
            all.append(greekPack.filter{ !Helper.isCaption($0) })
            all.append(greetingPack.filter{ !Helper.isCaption($0) })
            all.append(ratchetPack.filter{ !Helper.isCaption($0) })
        }
        return all
    }

}


