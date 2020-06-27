//
//  ContentView.swift
//  NapApp WatchKit Extension
//
//  Created by Mark Schmidt on 2/29/20.
//  Copyright © 2020 Mark Schmidt. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var times = [20, 30, 40, 50, 60, 75, 90, 120]
    @State private var selectedTimeIndex = 0;
    
    var body: some View {
        
        
        GeometryReader() {
            geometry in self.TimerView(geometry: geometry)


        }
        .edgesIgnoringSafeArea([.bottom])
    }
    
    private func TimerView(geometry: GeometryProxy) -> some View {
        return
            VStack {
                Text("Set Nap Length").frame(maxWidth: .infinity, alignment: .leading)
    
                Picker(selection: self.$selectedTimeIndex, label: Text("")) {
                    ForEach(0 ..< self.times.count) {
                        Text(String(self.times[$0]) + " minutes")
                    }
                }.padding(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    
                Button("Start", action: {
                    let time = self.times[self.selectedTimeIndex]
                    print("Start Pressed, selected time " + String(time))
                })
                .accentColor(Color.green)
                    // Frame uses bottom safe area because side safe area is only 0.5 for some unknown reason on series 4/5
                .frame(width: geometry.frame(in: .global).width - geometry.safeAreaInsets.bottom, height: 44, alignment: Alignment(horizontal: .center, vertical: .center))
//
            }
    }
    
}


struct TimerView: View {
    var body: some View {
        Text("Timer View")
    }
}

struct AlarmView: View {
    var body: some View {
        Text("Alarm View")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
