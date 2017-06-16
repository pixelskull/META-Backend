//
//  ComputeUnitDataSource.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 16.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

protocol ComputeUnitDataSource{
    var data:[Any] { get set }
    var results:[Any] { get set }
    
    var dataSemaphore:DispatchSemaphore { get set }
    var resultSemaphore:DispatchSemaphore { get set }
    
    init(data: [Any])
    
    func hasNextElement() -> Bool
    func getNextElement() -> Any?
    
    func hashNextResult() -> Bool
    func getNextResult() -> Any?
    
    func storeNextResult(_ result: Any)
}

enum MetaComputeUnitDataSourceDataSet {
    case Result
    case Data
}
