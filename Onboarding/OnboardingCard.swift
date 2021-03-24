//
//  OnboardingCard.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 23.03.21.
//

import Foundation

struct OnboardingCard : Identifiable {
    var id = UUID()
    var image: String
    var title: String
    var description: String
    var button: String = "Next"
}
