//
//  ComputeUnitHandler.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 19.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

/// protocol to implement an ComputeUnitHandler **legacy**
protocol ComputeUnitHandling {
    /// data to compute
    var data:[Any]! { get set }
    
    init()
    init(data:[Any])
    
    /// computing given data
    func compute(withData data:[Any]) -> [Any]
}

struct ComputeUnitHandler: ComputeUnitHandling {
    
    var data:[Any]!
    
    init() {
        data = [Any]()
    }
    
    init(data: [Any]) {
        self.init()
        
    }
    
    func compute(withData data: [Any]) -> [Any] {
        return data //TODO: Implement this 
    }
    
    
}
