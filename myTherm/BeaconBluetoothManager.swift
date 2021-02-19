import Foundation
import CoreBluetooth
import CoreLocation
import CoreData

/// This manages a bluetooth peripheral. This is intended as a starting point
/// for you to customise from.
/// Read http://www.splinter.com.au/2019/05/18/ios-swift-bluetooth-le for a
/// background in how to set this all up.
class MyBluetoothManager {
    static let shared = MyBluetoothManager()

    private init() {
        print("MyBluetoothmanager init called")
    }
        
    let central = CBCentralManager(delegate: MyCentralManagerDelegate.shared, queue: nil)
  
    func setMoc(moc: NSManagedObjectContext){
        MyCentralManagerDelegate.shared.setMoc(moc: moc)
    }
}

class MyCentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    static let shared = MyCentralManagerDelegate()
    private var moc: NSManagedObjectContext!
    private var lm = LocationManager()

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            central.scanForPeripherals(withServices: nil, options: nil)
        @unknown default:
            print("central.state is @unknown default")
        }
    }
}

extension MyCentralManagerDelegate {
    
    func setMoc(moc: NSManagedObjectContext){
        if (self.moc == nil) {
            print("MyCentralManagerDelegate setModel not set yet")
        }
        self.moc = moc
        print(" MyCentralManagerDelegatesetModel set")
    }

    func fetchBeacon(with identifier: UUID) -> Beacon? {
        let fetchRequest: NSFetchRequest<Beacon> = Beacon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "uuid", identifier as CVarArg)

        // Perform the fetch with the predicate
        do {
            let beacons: [Beacon] = try MyCentralManagerDelegate.shared.moc.fetch(fetchRequest)
            return beacons.first
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }

        return nil
    }
    
    func extractBeaconFromAdvertisment(advertisementData: [String : Any]) -> ( ExtractBeacon, ExtractBeaconAdv ) {
        var extractBeacon = ExtractBeacon(beacon_version: 0, company_id: 0, id_maj: "", id_min: "", name: "", descr: "")
        var extractBeaconAdv = ExtractBeaconAdv(temperature: -40.0, humidity: 0, battery: 0, accel_x: 0, accel_y: 0, accel_z: 0, rawdata: "")
        
        guard let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data else {
            return ( extractBeacon, extractBeaconAdv )
        }
        let arraylen: Int = manufacturerData.count
        
        if arraylen < 4 {
            print("centralManager: advertisementData too short, len \(arraylen) < 4")
            return ( extractBeacon, extractBeaconAdv )
        }

        let companyId = Int16(UInt16(manufacturerData[1]) << 8 + UInt16(manufacturerData[0]))
        if companyId == 0x0059 {
            extractBeacon.company_id = companyId
        } else {
            print("beac wrong companyId: \(companyId)")
            return ( extractBeacon, extractBeaconAdv )
        }
        
        let deviceType = Int16(manufacturerData[2])
        
        if ( (deviceType == 0x02 && arraylen > 11) || (deviceType == 0x00 && arraylen > 5)) { } else {
            print("beac array too short, arraylen: \(arraylen)")
            return ( extractBeacon, extractBeaconAdv )
        }
        
        switch deviceType {
        case 0x02:
            extractBeacon.beacon_version = 3
            extractBeacon.id_maj = String(format: "0x%02X%02X",
                                          UInt8(manufacturerData[8]),
                                          UInt8(manufacturerData[9]))
            extractBeacon.id_min = String(format: "0x%02X%02X",
                                          UInt8(manufacturerData[10]),
                                          UInt8(manufacturerData[11]))
        case 0x00:
            extractBeacon.beacon_version = 4
            extractBeacon.id_maj = String(format: "0x%02X%02X",
                                          UInt8(0),
                                          UInt8(UInt8(manufacturerData[3])))
            extractBeacon.id_min = String(format: "0x%02X%02X",
                                          UInt8(UInt8(manufacturerData[4])),
                                          UInt8(UInt8(manufacturerData[5])))
            print("maj \(0<<8 | UInt8(manufacturerData[3])) min \(UInt8(manufacturerData[4]) | UInt8(manufacturerData[5]))")
        default:
            print("beac wrong deviceType: \(deviceType)")
            return ( extractBeacon, extractBeaconAdv )
        }
        
        var tempVal : UInt16 = 0
        var humVal : UInt16 = 0
        var rawX : Int = 0
        var rawY : Int = 0
        var rawZ : Int = 0
        var battVal : Int64 = 0
        
        if extractBeacon.beacon_version == 4 {
            tempVal = UInt16(manufacturerData[6]) << 8 + UInt16(manufacturerData[7])
            humVal =  UInt16(manufacturerData[8]) << 8 + UInt16(manufacturerData[9])
            
            // attention, first LSB than MSB (in contrast to all other values)
            rawX =   Int(UInt16(manufacturerData[11]) << 8 + UInt16(manufacturerData[10]))
            rawY =   Int(UInt16(manufacturerData[13]) << 8 + UInt16(manufacturerData[12]))
            rawZ =   Int(UInt16(manufacturerData[15]) << 8 + UInt16(manufacturerData[14]))
            
            battVal = Int64(UInt16(manufacturerData[16]) << 8 + UInt16(manufacturerData[17]))
        }
        
        let accelX = Double((rawX > 0x7fff ?  Double(rawX - 0x10000) : Double(rawX)))/16384.0
        let accelY = Double((rawY > 0x7fff ?  Double(rawY - 0x10000) : Double(rawY)))/16384.0
        let accelZ = Double((rawZ > 0x7fff ?  Double(rawZ - 0x10000) : Double(rawZ)))/16384.0
        let temperature: Double = -45 + Double(tempVal) * 175 / 0xFFFF
        let humidity: Double = Double(humVal) * 100 / 0xFFFF

        extractBeaconAdv.temperature = temperature
        extractBeaconAdv.humidity = humidity
        extractBeaconAdv.battery = battVal
        extractBeaconAdv.accel_x = accelX
        extractBeaconAdv.accel_y = accelY
        extractBeaconAdv.accel_z = accelZ
        extractBeaconAdv.rawdata = (manufacturerData.hexEncodedString(options: .upperCase) as String).group(by: 4, separator: " ")


        print("temperature \(temperature), humidity \(humidity)")

        return ( extractBeacon, extractBeaconAdv )
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        /*
         for my own beacon code (github.com/an-erd/ble_beacon (running on hardware from radioland china/Alibaba), the
         following "kCBAdvDataManufacturerData" is received:
         
         AD Data: (key: "kCBAdvDataManufacturerData", value: <59000215 01122334 00070003 c365497c d670ff24 01143f0b c4>)
         
         The values mean:
         
         company_id         [0..1]      0x0059              company id from bluetooth.org = NORDIC
         device type        [2]         02                  = beacon
         adv data len       [3]         0x15 = 21           length of manufacturer specific data in the advertisement
         
         beac uuid short    [4..7]      0x01 0x12 0x23 0x34
         beac maj           [8..9]      0x00 0x07
         beac min           [10..11]    0x00 0x06
         measured power     [12]        c3 = -61            dBm @ 1m, 1 byte/2er complement
         uint16_t temp      [13..14]    6549                MSB, LSB, use calculation based on raw sensor data, see data sheet
         uint16_t humidity  [15..16]    7cdf                MSB, LSB, use calculation based on raw sensor data, see data sheet
         uint16_t x         [17..18]    70ff                attention: LSB first, than MSB, 2er complement
         uint16_t y         [19..20]    2401                -- " --
         uint16_t z         [21..22]    143f                -- " --
         uint16_t battery   [23..24]    0bc4                MSB, LSB
         */

//        print(advertisementData)

        let (extractBeacon, extractBeaconAdv) = extractBeaconFromAdvertisment(advertisementData: advertisementData)
        if(extractBeacon.beacon_version != 4){
            return
        }
        
        var beaconFind: Beacon?
        if let alreadyAvailableBeacon = fetchBeacon(with: peripheral.identifier) {
            beaconFind = alreadyAvailableBeacon
        } else {
            beaconFind = Beacon(context: MyCentralManagerDelegate.shared.moc)
            if let beacon = beaconFind {
                beacon.uuid = peripheral.identifier
                beacon.company_id = extractBeacon.company_id
                beacon.id_maj = extractBeacon.id_maj
                beacon.id_min = extractBeacon.id_min
                beacon.beacon_version = extractBeacon.beacon_version
                beacon.name = peripheral.name ?? "(no name)"
                
                beacon.adv = BeaconAdv(context: MyCentralManagerDelegate.shared.moc)
                guard let newadv = beacon.adv else { return }

                print(beacon)
                print("add new beacon \(peripheral.identifier)")
                print("inverse \(newadv.beacon?.name ?? "inverse beacon not set")")
            }
        }

        guard let beacon = beaconFind else { return }
        guard let beaconadv = beacon.adv else { return }

        beaconadv.rssi = RSSI.int64Value
        beaconadv.timestamp = Date()
        beaconadv.temperature = extractBeaconAdv.temperature
        beaconadv.humidity = extractBeaconAdv.humidity
        beaconadv.battery = extractBeaconAdv.battery
        beaconadv.accel_x = extractBeaconAdv.accel_x
        beaconadv.accel_y = extractBeaconAdv.accel_y
        beaconadv.accel_z = extractBeaconAdv.accel_z
        beaconadv.rawdata = extractBeaconAdv.rawdata
        
//        if let location = lm.location {
//            print(location)
//            if let _ = beacon.location { } else {
//                beacon.location = BeaconLoation(context: MyCentralManagerDelegate.shared.moc)
//            }
//            guard let beaconloc = beacon.location else { return }
//            beaconloc.latitude = location.latitude
//            beaconloc.longitude = location.longitude
//            beaconloc.timestamp = Date()
//        }
        
        PersistenceController.shared.saveBackgroundContext(backgroundContext: MyCentralManagerDelegate.shared.moc)
//        do {
//            try MyCentralManagerDelegate.shared.moc.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
    }
}
