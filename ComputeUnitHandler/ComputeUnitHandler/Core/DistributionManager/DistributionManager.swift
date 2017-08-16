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

//// protocol for implementing a total new DistributionManager if you like to do so
protocol DistributionManageable {
    /// compute unit to execute the computation
    var computeUnit:ComputeUnit { get }
    /// data source for feeding the compute unit
    var dataSource: ComputeDataSource { get }
    /// variable to get status of distribution manager
    var running: Bool { get }
    
    init()
    init(unit:ComputeUnit, dataSource:ComputeDataSource)
    /// function that distributes work over cores and threads
    func distribute()
    
}

class DistributionManager:DistributionManageable {
    /// private value for compute unit to make setting impossible
    private var _computeUnit:ComputeUnit!
    var computeUnit: ComputeUnit { get { return _computeUnit } }
    /// private value for data source to make setting impossible
    private var _dataSource: ComputeDataSource!
    var dataSource: ComputeDataSource { get {return _dataSource} }
    /// private value for running to make setting impossible
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
        dataSource.data.forEach { computeData in
            let queue = DispatchQueue(label: "ComputeUnitQueue", qos: .userInitiated)
            queue.async {
                let result = self.computeUnit.compute(data: computeData) //TODO: add here real data
                self.dataSource.storeNextResult(result)
                self.finishedElement()
            }
        }
    }
    
    private func finishedElement() {
        //TODO: Implement better way of waiting
        if dataSource.data.isEmpty {
            RabbitMQAdapter().publish(message: NSKeyedArchiver.archivedData(withRootObject: dataSource.results))
        }
    }
    
    private func finished() {
        RabbitMQAdapter().publish(message: NSKeyedArchiver.archivedData(withRootObject: dataSource.results))
    }
}
