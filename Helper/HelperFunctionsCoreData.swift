//
//  HelperFunctionsCoreData.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 13.03.21.
//

import Foundation
import CoreData
import SwiftUI

struct FilteredList<T: NSManagedObject, Content: View>: View {
    var fetchRequest: FetchRequest<T>
    var items: FetchedResults<T> { fetchRequest.wrappedValue }

    let content: (T) -> Content

    var body: some View {
        List(items, id: \.self) { item in
            self.content(item)
        }
    }

//    init(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor] = [], @ViewBuilder content: @escaping (T) -> Content) {
//        fetchRequest = FetchRequest<T>(entity: T.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
//        self.content = content
//    }
    init(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor] = [], @ViewBuilder content: @escaping (T) -> Content) {
        fetchRequest = FetchRequest<T>(entity: T.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
        self.content = content
    }
}
