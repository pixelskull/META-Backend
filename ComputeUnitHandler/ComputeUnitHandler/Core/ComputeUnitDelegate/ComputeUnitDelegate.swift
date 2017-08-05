//
//  ComputeUnitDelegate.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 21.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

public protocol ComputeUnitDelegatable {
    
    init()
    
    func computeUnitUpdatedResults()
    
    func computeUnitCompletedResult(_ result: Any)
    
    func computeFailedProducingResults(element: Any, error: Error)
    
    // TODO: add needfull stuff
    
}

public struct ComputeUnitDelegate: ComputeUnitDelegatable {
    
    public init() { self.init() }
    
    public func computeUnitUpdatedResults() {
        
    }
    
    public func computeUnitCompletedResult(_ result: Any) {
        
    }
    
    public func computeFailedProducingResults(element: Any, error: Error) {
        
    }
    
}
