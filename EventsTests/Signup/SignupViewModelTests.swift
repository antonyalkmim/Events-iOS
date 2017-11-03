//
//  SignupViewModelTests.swift
//  EventsTests
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Quick
import Nimble

@testable import Events


class SignupViewModelTests: QuickSpec {
    
    override func spec() {

        describe("when user has already registered fingerprint") {
            it("should request user fingerprint") {
                
            }
        }
        
        describe("when user fullfill signup or login fields") {
            context("and try to signup or login") {
                it("should filled not empty username") {
                    
                }
                it("should filled a valid birthday") {
                    
                }
            }
        }
        
        describe("signup") {
            describe("when user registered") {
                it("should ask user to enable login with touchID") {
                    
                }
                
                context("and has accepted login with touchID") {
                    it("should register user fingerprint"){
                        
                    }
                }
                
            }
            
        }
        
        
        
        
    }
    
}
