//
//  EventAddViewModelTests.swift
//  EventsTests
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Quick
import Nimble

@testable import Events


class EventAddViewModelTests: QuickSpec {
    
    override func spec() {
        
        describe("when try to register new event") {
            it("should validate filled event info") {
                
            }
            
            context("and event is already registered") {
                it("should alert user with duplicated event message") {
                    
                }
            }
            
            context("and has filled valid event info") {
                it("should send new event to API") {
                    
                }
                
                context("and has registered new event in API") {
                    it("should register new event in local database") {
                        
                    }
                    
                    it("should ask to add event in phone calendar") {
                        
                    }
                }
            }
            
        }
        
    }
    
}
