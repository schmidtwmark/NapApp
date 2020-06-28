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

var session = WKExtendedRuntimeSession()
var delegate = ExtensionDelegate()


let emojis = ["🐑", "💤", "😴"]
struct NapView: View {
    private let targetTime : Date
    
    init(targetTime : Date) {
        self.targetTime = targetTime
        // TODO start session
//        session.delegate = delegate
//        session.start(at: target)
//        print("Session started")
    }
    
    var body: some View {
        GeometryReader {
            geometry in
            ZStack {
                VStack {
                        Text("Waking around")
                        Text(self.dateFormatTime(date: self.targetTime))
                            .font(.system(size: geometry.frame(in: .global).width * 0.25))
                    }
                CharacterArc(geometry: geometry, character: emojis[0])
            }
        }.navigationBarTitle("Cancel")
            .edgesIgnoringSafeArea(.vertical)
        
//            .frame(width: .infinity, height: 44, alignment: .center)
    }
    
    func dateFormatTime(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
}

struct CharacterArc : View {
    private let width : CGFloat
    private let height : CGFloat
    private let character : String
    private let path : Path
    
    @State private var t: Double = 0.0
    init(geometry: GeometryProxy, character: String ) {
        self.width = geometry.frame(in: .global).width
        self.height = geometry.frame(in: .global).height
        self.character = character

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
//        print("t: " + String(format: "%.2f", t) + " x: " + String(format: "%2f", x) + " y: " + String(format: "%2f", y))
        print(String(format: "%.2f", t) + " " + String(format: "%2f", x) + " " + String(format: "%2f", y))
        return y
    }
    
    var body : some View {
        Text(character).position(pointAlongPath(t: CGFloat(adjustParameter(t: t))))
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .default).autoconnect(),
                perform: {
                    self.t = $0.timeIntervalSince1970.truncatingRemainder(dividingBy: 1)
                }
        )

    }
}

struct NapView_Previews: PreviewProvider {
    static var previews: some View {
        NapView(targetTime: Date().advanced(by: 8*60*60))
    }
}
