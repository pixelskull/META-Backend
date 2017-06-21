//
//  DistributionManager.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 19.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

protocol DistributionManageable {
    
    var computeUnit:ComputeUnit { get }
    
    init()
    init(unit:ComputeUnit)
    
    func distribute()
    
}

struct DistributionManager:DistributionManageable {
    
    private var _computeUnit:ComputeUnit
    var computeUnit:ComputeUnit { get { return _computeUnit } }
    
    init() {
        _computeUnit = ComputeUnit()
    }
    
    init(unit:ComputeUnit) {
        _computeUnit = unit
    }
    
    func distribute() {
        _ = computeUnit.compute(data: "foo") //TODO: add here data
    }
}
