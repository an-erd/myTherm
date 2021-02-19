
//
//  HelperFunctions.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 27.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//

import Foundation
import CoreData

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
}

extension String
{
    func group(by groupSize:Int=3, separator:String="-") -> String
    {
        if self.count <= groupSize   { return self }
        
        let splitSize  = min(max(2, self.count-2) , groupSize)
        let splitIndex = index(startIndex, offsetBy:splitSize)

        return String(self.prefix(upTo: splitIndex))
            + separator
            + (String(self.suffix(from: splitIndex))).group(by: groupSize, separator: separator)
    }
}

extension String {
    var drop0xPrefix:          String { return hasPrefix("0x") ? String(self.dropFirst(2)) : self }
    var drop0bPrefix:          String { return hasPrefix("0b") ? String(self.dropFirst(2)) : self }
    var hexaToDecimal:            Int { return Int(drop0xPrefix, radix: 16) ?? 0 }
    var hexaToBinaryString:    String { return String(hexaToDecimal, radix: 2) }
    var decimalToHexaString:   String { return String(Int(self) ?? 0, radix: 16) }
    var decimalToBinaryString: String { return String(Int(self) ?? 0, radix: 2) }
    var binaryToDecimal:          Int { return Int(drop0bPrefix, radix: 2) ?? 0 }
    var binaryToHexaString:    String { return String(binaryToDecimal, radix: 16) }
}

extension Int {
    var toBinaryString: String { return String(self, radix: 2) }
    var toHexaString:   String { return String(self, radix: 16) }
}

extension Set {
    subscript(member: Element) -> Bool {
        get { contains(member) }
        set {
            if newValue {
                insert(member)
            } else {
                remove(member)
            }
        }
    }
}

struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    typealias Index = Base.Index
    typealias Element = (index: Index, element: Base.Element)
    
    let base: Base
    
    var startIndex: Index { base.startIndex }
    
    var endIndex: Index { base.startIndex }
    
    func index(after i: Index) -> Index {
        base.index(after: i)
    }
    
    func index(before i: Index) -> Index {
        base.index(before: i)
    }
    
    func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }
    
    subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}

extension Double {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
