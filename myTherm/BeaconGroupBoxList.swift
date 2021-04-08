//
//  BeaconGroupBoxList.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 14.03.21.
//

import SwiftUI
import SwipeCell

struct BeaconGroupBoxList: View {
    
    var fetchRequest: FetchRequest<Beacon>
    init(predicate: NSPredicate?) {
        fetchRequest = FetchRequest<Beacon>(entity: Beacon.entity(),
                                            sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
                                            predicate: predicate,
                                            animation: .default)
    }
    
    @State var nowDate: Date = Date()
    @State private var displaySteps: Int = 0    // 0 temp, 1 hum

    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in     // PROFILE
            self.nowDate = Date()
        }
    }

    var body: some View {
    
        VStack {
            ForEach(fetchRequest.wrappedValue, id: \.self) { beacon in
                
                // Configure buttons
                let button_flag = SwipeCellButton(
                    buttonStyle: .view,
                    title: "",
                    systemImage: "",
                    titleColor: .white,
                    imageColor: .white,
                    view: {
                        AnyView(
                            Group {
                                if !beacon.flag {
                                    VStack {
                                        Image(systemName: "flag.fill")
                                            .font(.title2)
                                            .padding(.bottom, 5)
                                        Text("Flag")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                } else {
                                    VStack {
                                        Image(systemName: "flag.slash.fill")
                                            .font(.title2)
                                            .padding(.bottom, 5)
                                        Text("Unflag")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                        )
                    },
                    backgroundColor: .orange,
                    action: { beacon.flag.toggle() },
                    feedback: true
                )
                let slot1 = SwipeCellSlot(slots: [button_flag], slotStyle: .delay)

                BeaconGroupBoxListEntry(beacon: beacon,
                                        nowDate: nowDate,
                                        displaySteps: $displaySteps)
                    .listRowInsets(EdgeInsets())
                    .swipeCell(cellPosition: .left, leftSlot: slot1, rightSlot: nil)
                    .cornerRadius(10)
                    .padding(10)
            }
//            .navigationTitle("Beacons")
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            _ = self.timer
        })
    }
}

