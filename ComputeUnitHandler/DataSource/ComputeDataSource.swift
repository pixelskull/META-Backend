//
//  ComputeUnitDataSource.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 16.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

//class ComputeDataSource: ComputeUnitDataSource, Equatable {
class ComputeDataSource: ComputeUnitDataSource {
    
    var data: [Any]       = [Any]()
    var results: [Any]    = [Any]()
    
    var dataSemaphore: DispatchSemaphore
    var resultSemaphore: DispatchSemaphore
    
    init() {
        dataSemaphore   = DispatchSemaphore(value: 1)
        resultSemaphore = DispatchSemaphore(value: 1)
        data            = [Any]()
        results         = [Any]()
    }
    
    required convenience init(data: [Any]) {
        self.init()
        self.data = data
    }
    
    private func getElementFrom(dataSet: MetaComputeUnitDataSourceDataSet,
                                semaphore: DispatchSemaphore) -> Any? {
        guard !data.isEmpty else { return nil }
        semaphore.wait()
        let result: Any?
        switch dataSet {
        case .Result:
            result = results.removeFirst()
        default:
            result = data.removeFirst()
        }
        semaphore.signal()
        
        return result
    }
    
    
    func hasNextElement() -> Bool {
        return data.first != nil
    }
    
    func getNextElement() -> Any? {
        return getElementFrom(dataSet: .Data, semaphore: dataSemaphore)
    }
    
    
    func hashNextResult() -> Bool {
        return results.first != nil
    }
    
    func getNextResult() -> Any? {
        return getElementFrom(dataSet: .Result, semaphore: resultSemaphore)
    }
    
    
    func storeNextResult(_ result: Any) {
        resultSemaphore.wait()
        results.append(result)
        resultSemaphore.signal()
    }
    
}

extension ComputeDataSource: Equatable {
    static func ==(lhs: ComputeDataSource, rhs: ComputeDataSource) -> Bool {
        return lhs.data.count == rhs.data.count &&
            lhs.results.count == rhs.results.count
    }
}
