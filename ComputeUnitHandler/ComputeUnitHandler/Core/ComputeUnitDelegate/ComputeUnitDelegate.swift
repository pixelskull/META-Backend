//
//  ComputeUnitDelegate.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 21.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

/// protocol for implementing ComputeUnitDelegate **not used at the moment**
public protocol ComputeUnitDelegatable {
    
    init()
    /// gets called everytime a new result is set
    func computeUnitUpdatedResults()
    /// gets called everytime a new result is set. Gives you direct access to the element.
    func computeUnitCompletedResult(_ result: Any)
    /// gets called if something went wrong **not implemented yet**
    func computeFailedProducingResults(element: Any, error: Error)

}

/// Really dumb implementation. This does nothing 
public struct ComputeUnitDelegate: ComputeUnitDelegatable {
    
    public init() { self.init() }
    
    public func computeUnitUpdatedResults() {
        
    }
    
    public func computeUnitCompletedResult(_ result: Any) {
        
    }
    
    public func computeFailedProducingResults(element: Any, error: Error) {
        
    }
    
}
