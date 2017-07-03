//
//  Cache.swift
//  Eboticon1.2
//
//  Created by Johnson Ejezie on 02/07/2017.
//  Copyright © 2017 Incling. All rights reserved.
//

import Foundation

@objc final class CachedWebservice:NSObject {
    let webservice:Webservice
    init(_ webservice:Webservice) {
        self.webservice = webservice
    }
    let cache = Cache()
    func load<A>(_ resource:Resource<A>, update:@escaping (Result<A>) -> ()) {
        if let result = cache.load(resource) {
            update(.success(result))
        }
        
        let dataResource = Resource<Data>(url: resource.url, parse: {$0}, method: resource.method)
        webservice.load(resource: dataResource) { (result) in
            switch result {
            case let .error(error):
                update(.error(error))
            case let .success(data):
                self.cache.save(data, for: resource)
                let result = Result(resource.parse(data), or: WebserviceError.other)
                update(result)
            }
        }
    }
}

final class Cache {
    
    var storage = FileStorage()
    func load<A>(_ resource:Resource<A>) -> A? {
        guard case .get = resource.method else {return nil}
        let data = storage[resource.cacheKey]
        return data.flatMap(resource.parse)
    }
    
    func save<A>(_ data:Data, for resource:Resource<A>) {
        //Ensure we only cache get request
        guard case .get = resource.method else {return}
        storage[resource.cacheKey] = data
    }
}

struct FileStorage {
    let baseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    subscript(key:String) -> Data? {
        get {
            let url = baseURL.appendingPathComponent(key)
            return try? Data(contentsOf: url)
        }
        set {
            let url = baseURL.appendingPathComponent(key)
            _ = try? newValue?.write(to: url)
        }
    }
}

public enum Result<A> {
    
    case success(A)
    
    case error(Error)
}

extension Result {
    public init(_ value: A?, or error: Error) {
        if let value = value {
            self = .success(value)
        } else {
            self = .error(error)
        }
    }
    
    public var value: A? {
        guard case .success(let v) = self else { return nil }
        return v
    }
}
