//
//  RxMoya+Codable.swift
//  Events
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Foundation
import Moya
import RxSwift

enum EventsAPIError: String {
    case couldNotParseJSON
    case notLoggedIn
    case missingData
}

extension EventsAPIError: Swift.Error { }

extension PrimitiveSequence where Trait == RxSwift.SingleTrait, Element == Moya.Response {
    
    func mapTo<B: Decodable>(_ type: B.Type) -> RxSwift.PrimitiveSequence<Trait, B> {
        
        return self.map { response in
            if let object = try? jsonDecoder().decode(type, from: response.data) {
                return object
            } else {
                throw EventsAPIError.couldNotParseJSON
            }
        }
    }
}

