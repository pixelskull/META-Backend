//
//  DistributionManager.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 19.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation
import Dispatch

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
//        let queue = DispatchQueue(label: "ComputeUnitQueue", attributes: .concurrent)
        let queue = DispatchQueue(label: "ComputeUnitQueue", qos: .userInitiated)
        queue.async {
            _ = self.computeUnit.compute(data: "foo") //TODO: add here real data
        }
    }
}
