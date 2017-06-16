//
//  BasicDistributor.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 16.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation
import Dispatch

protocol BasicDistributor {
    var dataSource:ComputeUnitDataSource! { get }
    
    //    var shouldStop:Bool { get set } TODO: readd this when execution is clear 
    
    init(dataSource:ComputeUnitDataSource)
    
    func startDistribution()
//    func stopDistribution()
}

extension BasicDistributor {
    
    init(dataSource:ComputeUnitDataSource) {
        self.dataSource = dataSource
//        self.shouldStop = false
    }
    
    func startDistribution() {
        let result = dataSource.data.map {
            let queue = DispatchQueue(label: String($0))
            queue.async {
                //TODO: add ComputeUnit here
            }
        }
    }
    
    
}
