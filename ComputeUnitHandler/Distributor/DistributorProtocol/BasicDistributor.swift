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
    var dataSource:ComputeUnitDataSource! { get set }
    
    //    var shouldStop:Bool { get set } TODO: readd this when execution is clear 
    
    init()
    init(dataSource:ComputeUnitDataSource)
    
    func startDistribution()
//    func stopDistribution()
}

extension BasicDistributor {
    
    init(computeDataSource:ComputeUnitDataSource) {
        self.init()
        dataSource = computeDataSource
//        self.shouldStop = false
    }
    
    func startDistribution() {
        let result = dataSource.data.map {
            let queue = DispatchQueue(label: String(describing: $0))
            queue.async {
                //TODO: add ComputeUnit here
            }
        }
        print(result)
    }
    
    
}
