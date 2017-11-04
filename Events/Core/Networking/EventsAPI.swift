//
//  EventsAPI.swift
//  Events
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Moya

enum EventsAPI {
    case addEvent(event: Event)
}


extension EventsAPI: TargetType {
    
    var base: String { return "http://www.mocky.io/v2" }
    var baseURL: URL { return URL(string: base)! }
    
    var method: Method {
        switch self {
        case .addEvent(_):
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .addEvent(_):
            return "/59a1f3e025000028088d66fb"
        }
    }
    
    var task: Task {
        return Task.requestPlain
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        switch self {
        case .addEvent(_):
            return stubbedResponse("listPromotions")
        }
    }
    
}


func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

func stubbedResponse(_ filename: String, bundle: Bundle? = nil) -> Data! {
    @objc class TestClass: NSObject { }
    
    let bundle = bundle ?? Bundle(for: TestClass.self)
    let path = bundle.path(forResource: filename, ofType: "json")
    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
}

extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}


