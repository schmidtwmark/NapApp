//
//  HeartData.swift
//  NapApp WatchKit Extension
//
//  Created by Mark Schmidt on 6/28/20.
//  Copyright © 2020 Mark Schmidt. All rights reserved.
//

import Foundation
import SwiftUI

struct HeartRateSample {
    public let heartRate :Double
    public let timestamp : Date
    
    init(_ heartRate : Double, _ timestamp : Date) {
        self.heartRate = heartRate
        self.timestamp = timestamp
    }
}

// Sample rate agnostic heart rate uptick detector
class HeartData : ObservableObject{
    @Published private var heartRates : [HeartRateSample]
    private var deltas : [Double]
    
    init(heartRates: [HeartRateSample] = []) {
        self.heartRates = heartRates
        self.deltas = []
        let start = 1
        let count = self.heartRates.count
        if count > 1 {
            for index in start..<count {
                deltas.append(self.heartRates[index].heartRate - self.heartRates[index - 1].heartRate)
            }
        }
    }
    
    public func getLastHeartRate() -> HeartRateSample? {
        let count = heartRates.count
        if count == 0 {
            return nil
        }
        return heartRates[count - 1]
    }
    
    public func append(heartRate: Double, timestamp: Date) {
        heartRates.append(HeartRateSample(heartRate, timestamp))
    }
    
    
    
}

