//
//  MotherView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 24.03.21.
//

import SwiftUI

struct MotherView : View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            if viewRouter.currentPage == "onboarding" {
                OnboardingView()
            } else if viewRouter.currentPage == "content" {
                withAnimation {
                    ContentView()
                }
            }
        }
    }
}

struct MotherView_Previews: PreviewProvider {
    static var previews: some View {
        MotherView().environmentObject(ViewRouter())
    }
}
