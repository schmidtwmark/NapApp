//
//  ExtensionDelegate.swift
//  NapApp WatchKit Extension
//
//  Created by Mark Schmidt on 2/29/20.
//  Copyright © 2020 Mark Schmidt. All rights reserved.
//

import WatchKit
import HealthKit
import Combine

class ExtensionDelegate: NSObject, WKExtensionDelegate, WKExtendedRuntimeSessionDelegate{
    
    var timer : Timer?
    public var healthStore : HKHealthStore = HKHealthStore()
    public var heartData : HeartData = HeartData()
    
    let heartRateQuantity = HKUnit(from: "count/min")

    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        
        print("extendedRuntimeSession didInvalidateWith")
        timer?.invalidate()
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extendedRuntimeSessionDidStart at " + Date().description + " will expire at " + extendedRuntimeSession.expirationDate!.description)

//        if(extendedRuntimeSession.state == WKExtendedRuntimeSessionState.running) {
//            extendedRuntimeSession.notifyUser(hapticType: WKHapticType.notification, repeatHandler: {_ in 4})
//        }
        print("Starting, session state \(extendedRuntimeSession)")
        subscribeToHeartBeatChanges()
    }
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extendedRuntimeSessionWillExpire")
        // TODO clean up timer and wake up the user here
        
    }
    
    func handle(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Launching handle function")
        extendedRuntimeSession.delegate = self
    }
    
    private func tick() {
        print("Ticking")
        self.startHeartRateQuery(quantityTypeIdentifier: .heartRate)
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { (_) in
            print("In timer")
            self.tick()
        })
    }
    
    public func subscribeToHeartBeatChanges() {
        // Creating the sample for the heart rate
        guard let sampleType: HKSampleType =
            HKObjectType.quantityType(forIdentifier: .heartRate) else {
                return
        }
        
        // Set up the immutable HKObserverQuery
        let heartRateQuery = HKObserverQuery.init(
            sampleType: sampleType,
            predicate: nil) {  query, completionHandler, error in
                // This is fired every time new samples are retrieved
                // This also seems to turn on active sensing to get heart rates every ~5 seconds
                guard error == nil else {
                    print("error with observer query")
                    return
                }
                // Get the actual query
                self.startHeartRateQuery(quantityTypeIdentifier: .heartRate)
                
                // Unclear if I actually need this, but it doesn't change anything
                completionHandler()

        }
        // Execute the actual query
        print("Subscribing to heart beats...")
        healthStore.execute(heartRateQuery)
    }
    

    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
           
        print("Starting heart rate query")
        // Set the predicate to get only samples from the last hour
        // Could be last minute and should be just fine
        let predicate = HKQuery
            .predicateForSamples(
                withStart: Date().addingTimeInterval(-3600),
                end: Date(),
            options: [])
        
        // Sort most recent
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)
        let query = HKSampleQuery(sampleType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
                                  predicate: predicate,
                                  limit: Int(1), //Get only one
                                  sortDescriptors: [sortDescriptor]) { query, results, error in
                                    // Fired when query completes
                                    guard let samples = results as? [HKQuantitySample] else {
                                        return
                                    }
                                    // Should only be one sample
                                    for s in samples {
                                        let heartRate = s.quantity.doubleValue(for: self.heartRateQuantity)
                                        let timestamp = s.endDate
                                        print("Recent heart rate: \(heartRate) at time \(timestamp)")
                                        // Log heart rate to my internal structure for processing
                                        DispatchQueue.main.async {
                                            self.heartData.append(
                                                heartRate: heartRate,
                                                timestamp: timestamp)
                                        }
                                    }
        }
        healthStore.execute(query)

    }


    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        print("Did finish launching")
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Did become active")
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        print("Resign active")
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
