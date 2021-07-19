//
//  HapticsManager.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 18.07.21.
//

import Foundation
import CoreHaptics

class HapticsManager {
    let hapticEngine: CHHapticEngine
    static let shared = HapticsManager()
    
    init?() {
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        guard hapticCapability.supportsHaptics else {
            return nil
        }
        do {
            hapticEngine = try CHHapticEngine()
        } catch let error {
            print("Haptic engine Creation Error: \(error)")
            return nil
        }
    }
    
    func playPull() {
        do {
            let pattern = try pullPattern()
            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticEngine.notifyWhenPlayersFinished { _ in
                return .stopEngine
            }
        } catch {
            print("Failed to play pull: \(error)")
        }
    }
    
    func playDip() {
        do {
            let pattern = try dipPattern()
            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticEngine.notifyWhenPlayersFinished { _ in
                return .stopEngine
            }
        } catch {
            print("Failed to play dip: \(error)")
        }
    }

    
}

extension HapticsManager {
    private func pullPattern() throws -> CHHapticPattern {
        let snip = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0.08) // .08

        return try CHHapticPattern(events: [snip], parameters: [])
    }
 
    private func dipPattern() throws -> CHHapticPattern {
        let dip = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0.0)

        return try CHHapticPattern(events: [dip], parameters: [])
    }

    
}
