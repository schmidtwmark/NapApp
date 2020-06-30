//
//  ContentView.swift
//  NapApp WatchKit Extension
//
//  Created by Mark Schmidt on 2/29/20.
//  Copyright © 2020 Mark Schmidt. All rights reserved.
//

import SwiftUI



var times = [5, 10, 20, 30, 40, 50, 60, 75, 90, 120]


func getTimeForIndex(index: Int) -> Date{
//    let minutes = times[index]
    let seconds = times[index]
    let now = Date()
//    let target = now.advanced(by: TimeInterval(seconds))
    let target = now.advanced(by: TimeInterval(seconds))
    return target
}
struct MainView: View {
    
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
                TimePicker(selectedTimeIndex: $selectedTimeIndex)
                StartButton(geometry: geometry, selectedTimeIndex: $selectedTimeIndex)
            }
    }
    
}

struct StartButton: View {
    private let geometry : GeometryProxy
    @Binding private var selectedTimeIndex : Int
    init(geometry: GeometryProxy, selectedTimeIndex:  Binding<Int>) {
        self.geometry = geometry
        self._selectedTimeIndex = selectedTimeIndex
    }
    var body: some View {
        NavigationLink(
        destination: NapView(targetTime: getTimeForIndex(index: self.selectedTimeIndex))) {
               Text("Start")
            }
        .accentColor(Color.green)
        // Frame uses bottom safe area because side safe area is only 0.5 for some unknown reason on series 4/5
        // I don't want to have to read the fucking device type to know which button to use
        .frame(width: geometry.frame(in: .global).width - geometry.safeAreaInsets.bottom, height: 44, alignment: Alignment(horizontal: .center, vertical: .center))
    }
}

struct TimePicker: View {
    
    @Binding private var selectedTimeIndex : Int

    init(selectedTimeIndex: Binding<Int>) {
        self._selectedTimeIndex = selectedTimeIndex
    }
    var body: some View {
        
        Picker(selection: $selectedTimeIndex, label: Text("")) {
            ForEach(0 ..< times.count) {
                Text(String(times[$0]) + " seconds")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
