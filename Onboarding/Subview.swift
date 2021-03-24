//
//  Subview.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 23.03.21.
//

import SwiftUI

struct Subview: View {
    
    var card: OnboardingCard
    
    var body: some View {
        VStack {
            Image(card.image)
                .resizable()
                .aspectRatio(contentMode: .fit)    // .fit
                .frame(width: 250, height: 250, alignment: .center)
                .clipShape(RoundedRectangle(cornerSize: /*@START_MENU_TOKEN@*/CGSize(width: 20, height: 10)/*@END_MENU_TOKEN@*/))
                .padding(.bottom, 20)
            Text(card.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(card.description)
                .lineLimit(4)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .frame(height: 120.0, alignment: .top)
        }
        .padding()
    }
}

struct Subview_Previews: PreviewProvider {
    static var previews: some View {
        Subview(card: cards[2])
        Subview(card: cards[3])
    }
}
