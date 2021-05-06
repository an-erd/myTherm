//
//  BeaconGroupBoxListUuidEntry.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 04.05.21.
//

import SwiftUI
import SwipeCell

struct BeaconGroupBoxListUuidEntry: View {
    var uuid: UUID
    @StateObject var beaconModel = BeaconModel.shared
    @State var date: Date
    @State var displaySteps: Int
    
    var beacon: Beacon {
        return beaconModel.fetchBeacon(context: PersistenceController.shared.viewContext, with: uuid)!
    }
    
    var body: some View {
        HStack {
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
                    if !beacon.hidden{
                        beaconModel.activeAlert = .hiddenAlert
                    }
                    beacon.hidden.toggle()
                },
                feedback: true
            )
            let slot2 = SwipeCellSlot(slots: [button_hide], slotStyle: .delay)
            
            //                Text("\(beacon.wrappedDeviceName)")
            // hitches
            withAnimation {
                BeaconGroupBoxListEntry(beacon: beacon,
                    nowDate: date)
//                    .equatable()
                    .listRowInsets(EdgeInsets())
                                            .swipeCell(cellPosition: .both, leftSlot: slot1, rightSlot: slot2)
                    .cornerRadius(10)
                    .padding(10)
            }
            
        }
    }
}

//struct BeaconGroupBoxListUuidEntry_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconGroupBoxListUuidEntry()
//    }
//}
