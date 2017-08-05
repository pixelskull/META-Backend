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
    
    init() 
    init(delegate: ComputeUnitDelegate)
    
    func compute<T>(data: T) -> T
    func compute<T>(data:T, WithAction action: (T) -> T) -> T
}

struct ComputeUnit: ComputeUnitable {
    
    var delegate: ComputeUnitDelegate!
    
    init() {
        self.init()
        self.delegate = ComputeUnitDelegate()
    }
    
    init(delegate: ComputeUnitDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    public func compute<T>(data: T) -> T {
        return data
    }
    
    public func compute<T>(data: T, WithAction action: (T) -> T) -> T {
        return action(data)
    }
    
}
