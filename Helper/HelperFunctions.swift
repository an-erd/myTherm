
//
//  HelperFunctions.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 27.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//

import SwiftUI
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

/*
 0-15 secs:             now
 15-180:                recently
 180/3m -3600/60min:    x minutes ago
 60min - 10h            x hours ago
 >10h:                  last seen (short date)
 */
func getDateInterpretationString(date: Date, nowDate: Date ) -> String {
    let formatter2 = DateFormatter()
    let _ = nowDate
    formatter2.dateFormat = "yy/MM/dd"

    let secs = date.timeIntervalSinceNow
    if secs > -15 {
        return "Now"
    } else if secs > -180 {
        return "Recently"
    } else if secs > -3600 {
        return "\(Int(-round(secs/60.0))) min. ago"
    } else if secs > -(10*3600) {
        return "\(Int(-round(secs/3600))) hour ago"
    } else {
        return "Seen " + formatter2.string(from: date)
    }
}

func getDateString(date: Date? ) -> String {
    let formatter2 = DateFormatter()
    formatter2.dateFormat = "yyyy/MM/dd HH:mm:ss"
    formatter2.timeZone = TimeZone(secondsFromGMT: 0)
    
    if let date = date {
        return formatter2.string(from: date)
    } else {
        return "never"
    }
}

func UInt16_decode(msb: UInt8, lsb: UInt8) -> UInt16 {
    return UInt16(msb) << 8 | UInt16(lsb)
}

func UInt32_decode(msb1: UInt8, msb0: UInt8, lsb1: UInt8, lsb0: UInt8) -> UInt32 {
    return UInt32(msb1) << 24 | UInt32(msb0) << 16 | UInt32(lsb1) << 8 | UInt32(lsb0)
}

func getSHT3temperatureValue(msb: UInt8, lsb: UInt8) -> Double {
    return Double(-45.0 + (Double(UInt16_decode(msb: msb, lsb: lsb)) * 175.0 ) / Double(0xFFFF))
}

func getSHT3humidityValue(msb: UInt8, lsb: UInt8) -> Double {
    return Double((Double(UInt16_decode(msb: msb, lsb: lsb)) * 100.0 ) / Double(0xFFFF))
}

