//
//  ContentView.swift
//  NapApp WatchKit Extension
//
//  Created by Mark Schmidt on 2/29/20.
//  Copyright © 2020 Mark Schmidt. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Group {
            Text("Hello Jam")
        }
        .contextMenu(menuItems: getMenuItems())
    }
    
}

func getMenuItems() -> View {
    return {
        Button(action: {
            print("Refresh")
        }, label: {
            VStack{
                Image(systemName: "arrow.clockwise")
                    .font(.title)
                Text("Refresh view")
            }
        })
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
