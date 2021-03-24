//
//  OnboardingView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 23.03.21.
//

import SwiftUI

var cards: [OnboardingCard] = [
    OnboardingCard(
        image: "thermo1",
        title: "Hello",
        description: "This is an app that allows you to display temperature and humidity values from your remote sensors."),
    OnboardingCard(
        image: "bluetooth_beacon",
        title: "Sensor",
        description: "The sensors communicate with bluetooth, thus you need to allow the app to use bluetooth when asked."),
    OnboardingCard(
        image: "key1",
        title: "On the way",
        description: "If you use them your sensors on the way, you can activate location services when asked. This enables the app to store the sensors last-seen position."),
    OnboardingCard(
        image: "startusing1",
        title: "Enjoy",
        description: "Place a sensor in operating distance (start with < 5 Meters) to your mobile and start using it.",
        button: "Start")
]

struct OnboardingView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @State var selectedPage: Int = 0
    
    var body: some View {
        TabView(selection: $selectedPage) {
            ForEach(0..<cards.count) { index in
                VStack {
                    Subview(card: cards[index]).tag(index)
                    HStack {
                        Button(action: {
                            if selectedPage == cards.count - 1 {
                                withAnimation {
                                    viewRouter.currentPage = "content"
                                }
                            } else {
                                withAnimation {
                                    selectedPage += 1
                                }
                            }
                        }) {
                            HStack {
                                HStack {
                                    Text(cards[index].button)
                                        .font(.headline)
                                        .frame(width: 80)
                                        .padding(10)
                                    Image(systemName: "arrow.right.circle")
//                                        .background(Circle().fill(Color.green))
                                        .imageScale(.large)
                                        .padding(10)
                                }
                                .foregroundColor(.primary)
                                .background(
                                    Capsule()
                                        .stroke(Color.primary, lineWidth: 2)
                                )
                                .padding()
                            }
                        }
                    }
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
