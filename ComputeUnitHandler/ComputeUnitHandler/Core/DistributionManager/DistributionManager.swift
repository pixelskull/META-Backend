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
    init(unit:ComputeUnit, dataSource:ComputeDataSource)
    
    func distribute()
    
}

struct DistributionManager:DistributionManageable {

    private var _computeUnit:ComputeUnit!
    var computeUnit: ComputeUnit { get { return _computeUnit } }
    
    private var _dataSource: ComputeDataSource!
    var dataSource: ComputeDataSource { get {return _dataSource} }
    
    init() {
        _computeUnit = ComputeUnit()
        _dataSource = ComputeDataSource()
    }
    
    init(unit:ComputeUnit,
         dataSource:ComputeDataSource) {
        _computeUnit = unit
        _dataSource = dataSource
    }
    
    func distribute() {
//        let queue = DispatchQueue(label: "ComputeUnitQueue", attributes: .concurrent)
        dataSource.data.forEach { computeData in
            let queue = DispatchQueue(label: "ComputeUnitQueue", qos: .userInitiated)
            queue.async {
                let result = self.computeUnit.compute(data: computeData) //TODO: add here real data
                self.dataSource.storeNextResult(result)
            }
        }
        
    }
}
