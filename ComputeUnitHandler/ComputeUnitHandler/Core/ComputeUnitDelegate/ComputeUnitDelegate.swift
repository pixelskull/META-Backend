//
//  ComputeUnitDelegate.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 21.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

protocol ComputeUnitDelegatable {
    
    init()
    
    func computeUnitUpdatedResults()
    
    func computeUnitCompletedResult(_ result: Any)
    
    func computeFailedProducingResults(element: Any, error: Error)
    
    // TODO: add needfull stuff
    
}

struct ComputeUnitDelegate: ComputeUnitDelegatable {
    
    init() { self.init() }
    
    func computeUnitUpdatedResults() {
        
    }
    
    func computeUnitCompletedResult(_ result: Any) {
        
    }
    
    func computeFailedProducingResults(element: Any, error: Error) {
        
    }
    
}
