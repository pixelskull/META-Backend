//
//  DistributionManager.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 19.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation
import Dispatch
import ComputeUnitModule

protocol DistributionManageable {
    
    var computeUnit:ComputeUnit { get }
    var dataSource: ComputeDataSource { get }
    
    var running: Bool { get }
    
    init()
    init(unit:ComputeUnit, dataSource:ComputeDataSource)
    
    func distribute()
    
}

class DistributionManager:DistributionManageable {

    private var _computeUnit:ComputeUnit!
    var computeUnit: ComputeUnit { get { return _computeUnit } }
    
    private var _dataSource: ComputeDataSource!
    var dataSource: ComputeDataSource { get {return _dataSource} }
    
    private var _running: Bool = false
    var running: Bool { get { return _running } }
    
    
    required init() {
        _computeUnit = ComputeUnit()
        _dataSource = ComputeDataSource()
    }
    
    convenience required init(unit:ComputeUnit,
         dataSource:ComputeDataSource) {
        self.init()
        _computeUnit = unit
        _dataSource = dataSource
    }
    
    func distribute() {
        _running = true
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
