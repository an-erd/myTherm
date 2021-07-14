//
//  NetworkManager.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 11.04.21.
//

import Foundation
import Network

class NetworkManager: ObservableObject {

    @Published var isConnected: Bool = false
    static var shared = NetworkManager()
    var monitor: NWPathMonitor!
    private var queue: DispatchQueue!

    init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
//                    print("NetworkManager Internet connected")
                    self.isConnected = true
                }
            } else {
                DispatchQueue.main.async {
                    print("NetworkManager Internet not connected")
                    self.isConnected = false
                }
            }

        }

    }
}

