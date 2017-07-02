//
//  Resource.swift
//  Eboticon1.2
//
//  Created by Johnson Ejezie on 02/07/2017.
//  Copyright © 2017 Incling. All rights reserved.
//

import Foundation

public struct Resource<A> {
    public var url:URL
    public var method:HttpMethod<Data> = .get
    public var parse:(Data) -> A?
    
    public init(url: URL, parse: @escaping (Data) -> A?, method: HttpMethod<Data> = .get) {
        self.url = url
        self.parse = parse
        self.method = method
    }
}

extension Resource {
    public init(url: URL, method: HttpMethod<Data> = .get, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.method = method
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}

extension Resource {
    var cacheKey: String {
        return "cache" + String(url.hashValue)
    }
}

//Mark:- NSMutableURLRequest
extension NSMutableURLRequest {
    convenience init<A>(resource:Resource<A>) {
        self.init(url:resource.url)
        httpMethod = resource.method.method
        if case let .post(data) = resource.method {
            httpBody = data
        }
    }
}


//Mark:- HttpMethod

public enum HttpMethod<A> {
    case get
    case post(data: A)
    
    public var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
    
    public func map<B>(f: (A) throws -> B) rethrows -> HttpMethod<B> {
        switch self {
        case .get: return .get
        case .post(let data): return .post(data: try f(data))
        }
    }
}
