//
//  ComputeUnitDelegate.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 16.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

protocol ComputeUnitDelegate {
    
    func computeUnitUpdatedResults()
    
    func computeUnitCompletedResult(_ result:Any)
    
    func computeFailedProducingResults(element: Any, error: Error)
    
    // TODO: add needfull stuff
    
}
