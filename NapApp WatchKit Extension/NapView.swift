//
//  NapView.swift
//  NapApp WatchKit Extension
//
//  Created by Mark Schmidt on 6/27/20.
//  Copyright © 2020 Mark Schmidt. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import HealthKit

var session : WKExtendedRuntimeSession?
var delegate = ExtensionDelegate()

let emojis = ["🐑", "💤", "😴"]
struct NapView: View {
    private let targetTime : Date

    init(targetTime : Date) {
        self.targetTime = targetTime
    }

    
    var body: some View {
        GeometryReader {
            geometry in
            ZStack {
                HeartRateView().offset(x: 0, y: CGFloat(-geometry.frame(in: .global).height * 0.25))
                VStack {
                        Text("Waking around")
                        Text(self.dateFormatTime(date: self.targetTime))
                            .font(.system(size: geometry.frame(in: .global).width * 0.25))
                    }
                CharacterArc(geometry: geometry, characters: emojis)
            }
        }
        .navigationBarTitle("Cancel")
        .edgesIgnoringSafeArea(.vertical)
        .onAppear(perform: start)
        .onDisappear(perform: stop)
        
        
    }
    
    func dateFormatTime(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    
    func start() {
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        
        delegate.healthStore.requestAuthorization(toShare: [], read: healthKitTypes) { _, _ in }
        
        print("Starting session!")
        session = WKExtendedRuntimeSession()
        session!.delegate = delegate
        session!.start(at: targetTime)
        
    }
    
    func stop() {
        print("Nap view disappearing")
        guard let session = session else {
            print("Cannot cancel session")
            return
        }
        session.invalidate()
        
    }
}

struct HeartRateView : View{
    @ObservedObject var heartData : HeartData = delegate.heartData
    
    var body : some View {
        getView()
    }
    private func getView() -> some View {
        if heartData.getLastHeartRate() != nil {
            return AnyView(Text("❤️ \(String(format: "%.0f", heartData.getLastHeartRate()!.heartRate)) BPM"))
        } else {
            return AnyView(EmptyView())
        }
        
    }
}

struct AnimationConfig {
    public var t: Double = 0.0
    public var index: Int = 0
}

struct CharacterArc : View {
    private let width : CGFloat
    private let height : CGFloat
    private let characters : Array<String>
    private let path : Path
    
    @State private var animationConfig = AnimationConfig()
    init(geometry: GeometryProxy, characters: Array<String>) {
        self.width = geometry.frame(in: .global).width
        self.height = geometry.frame(in: .global).height
        self.characters = characters

        let start = CGPoint(x: 0, y: -self.height / 2)
        let peak = CGPoint(x: self.width/2, y: -self.height / 4)
        let end = CGPoint(x: self.width, y: -self.height / 2)
        // animate from (0,-height/2), (width/2, -height/4), (width, -height/2)
        self.path = Path {
            path in
            path.move(to: start)
            path.addQuadCurve(to: end, control: peak)
        }
        
    
    }
    
    private func pointAlongPath(t : CGFloat) -> CGPoint{
        let w = self.width
        let h = self.height
        let x = w * t
        let y = h * (t * t - t + 1)
        return CGPoint(x: x, y: y)
    }
    
    private func adjustParameter(t : Double) -> Double {
        let x = (t - 0.5) * (Double.pi / 2)
        let y = (tan(x) + 1) / 2
        return y
    }
    
    var body : some View {
        Text(characters[animationConfig.index])
            .font(.system(size: self.width * 0.15))
            .position(pointAlongPath(t: CGFloat(adjustParameter(t: animationConfig.t))))
            .onReceive(Timer.publish(every: 0.01, on: .main, in: .default).autoconnect(),
                perform: {
                    let value = $0.timeIntervalSince1970 / 1.5
                    self.animationConfig.t = value.truncatingRemainder(dividingBy: 2)
                    self.animationConfig.index = Int(((value + 0.5) / 2).truncatingRemainder(dividingBy: TimeInterval(self.characters.count)))

                }
        )

    }
}

struct NapView_Previews: PreviewProvider {
    static var previews: some View {
        NapView(targetTime: Date().advanced(by: 8*60*60))
    }
}
