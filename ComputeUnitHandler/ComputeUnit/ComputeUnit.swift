//
//  ComputeUnit.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 16.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation


protocol ComputeUnitable {
    
    var delegate: ComputeUnitDelegate? { get set }
    
    init()
    init(delegate: ComputeUnitDelegate?)
    
    
    func compute<T>(data: T) -> T
    func compute<T>(data:T, WithAction action: (T) -> T) -> T
    
}


struct MetaComputeUnit: ComputeUnitable {
    
    var delegate: ComputeUnitDelegate?
    
    init() {
        self.init()
    }
    
    init(delegate: ComputeUnitDelegate?) {
        self.delegate   = delegate
    }
    
    
    func updateDelegate(WithResult result: Any) {
        guard let delegate = delegate else { return }
        delegate.computeUnitUpdatedResults()
        delegate.computeUnitCompletedResult(result)
    }
    
    /// Default implementation does nothing
    func compute<T>(data:T) -> T {
        updateDelegate(WithResult: data)
        return data
    }
    
    func compute<T>(data:T, WithAction action: (T) -> T) -> T {
        let result = action(data)
        updateDelegate(WithResult: result)
        return result
    }
}
