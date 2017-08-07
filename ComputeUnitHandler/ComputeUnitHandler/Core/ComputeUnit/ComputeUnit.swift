//
//  ComputeUnit.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 21.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

public protocol ComputeUnitable {
    
    var delegate: ComputeUnitDelegate! { get set }
    
    
    func compute(data: Any) -> Any
}

struct ComputeUnit: ComputeUnitable {
    
    var delegate: ComputeUnitDelegate!
    
    public func compute(data: Any) -> Any {
        return data
    }
    
}
