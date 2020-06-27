//
//  HostingController.swift
//  NapApp WatchKit Extension
//
//  Created by Mark Schmidt on 2/29/20.
//  Copyright © 2020 Mark Schmidt. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<MainView> {
    override var body: MainView {
        return MainView()
    }
}
