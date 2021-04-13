//
//  BeaconGroupBoxList.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 14.03.21.
//

import SwiftUI
import SwipeCell

struct BeaconGroupBoxList: View {
    @EnvironmentObject var lm: LocationManager
    @State private var showAlertForHidden = false

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
                
                let button_hide = SwipeCellButton(
                    buttonStyle: .view,
                    title: "",
                    systemImage: "",
                    titleColor: .white,
                    imageColor: .white,
                    view: {
                        AnyView(
                            Group {
                                if !beacon.hidden {
                                    VStack {
                                        Image(systemName: "eye.slash")
                                            .font(.title2)
                                            .padding(.bottom, 5)
                                        Text("Hide")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                } else {
                                    VStack {
                                        Image(systemName: "eye")
                                            .font(.title2)
                                            .padding(.bottom, 5)
                                        Text("Show")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                        )
                    },
                    backgroundColor: .gray,
                    action: {
                        if !beacon.hidden {
                            showAlertForHidden = true
                        }
                        beacon.hidden.toggle()
                    },
                    feedback: true
                )
                let slot2 = SwipeCellSlot(slots: [button_hide], slotStyle: .delay)

                withAnimation {
                    BeaconGroupBoxListEntry(beacon: beacon,
                                            nowDate: nowDate,
                                            displaySteps: $displaySteps)
                        .environmentObject(lm)
                        .listRowInsets(EdgeInsets())
                        .swipeCell(cellPosition: .both, leftSlot: slot1, rightSlot: slot2)
                        .cornerRadius(10)
                        .padding(10)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            _ = self.timer
        })
        .alert(isPresented: $showAlertForHidden) {
            Alert(
                title: Text("Hide sensor"),
                message: Text("Sensor will be marked as hidden. Find it again using sensor filter."),
                dismissButton: .default(Text("Got it!")
            )
        )}

    }
}

