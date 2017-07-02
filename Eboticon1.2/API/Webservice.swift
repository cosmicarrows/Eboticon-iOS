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

@objc final class Webservice: NSObject {
    func load<A>(resource:Resource<A>, completion:@escaping (Result<A>)->()) {
        let request = NSMutableURLRequest(resource: resource)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data,response, error) in
            let result: Result<A>
            let parse = data.flatMap(resource.parse)
            result = Result.init(parse, or: WebserviceError.other)
            completion(result)
        })
        task.resume()
    }
}

public enum WebserviceError: Error {
    case other
}


