//
//  BeaconExtension.swift
//  myTherm
//
//  Created by Andreas Erdmann on 19.02.21.
//

import Foundation

extension Beacon {
    
    var descrNonOptional: String {
        get { descr ?? "" }
        set { descr = newValue.isEmpty ? "" : newValue }
    }
}
