//
//  Error.swift
//  Authentication
//
//  Created by Amin Amjadi on 10/2/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import Foundation
import FirebaseCrash

class Error {
    
    private var knownError = [String:Err]()
    
    private enum Err {
        case UserService(Bool?)
    }
    
    private var saveErrorForUserService = [Err]()
    
    init() {
        knownError["UserService"] = Err.UserService(true)
    }
    
    func giveError(typeOfError: String) -> Bool {
        if let errType = knownError[typeOfError] {
            switch errType {
            case .UserService(_): //cz we don't care about the bool inside it we just care about saveError array
                if !saveErrorForUserService.isEmpty {
                    let getError = saveErrorForUserService.removeLast()
                    switch getError {
                    case .UserService(let error):
                        if let err = error {
                            return err
                        }
                    }
                } else {
                    
                }
//                } else {
//                    FIRCrashMessage("The saveError Array is empty")
//                    fatalError()
//                }
            }
        }
        return false
    }
    
    func changeError(typeOfError: String, error: Bool?) {
        if let errType = knownError[typeOfError] {
            switch errType {
            case .UserService(_):
                if saveErrorForUserService.count > 0 {
                saveErrorForUserService.removeAll()
                }
//                knownError[typeOfError] = Err.UserService(error)
                saveErrorForUserService.append(.UserService(error))
            }
        }
    }
    
}
