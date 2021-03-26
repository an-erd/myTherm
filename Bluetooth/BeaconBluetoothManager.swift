import Foundation
import CoreBluetooth
import CoreLocation
import CoreData
import os

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
        downloadManager.setMoc(moc: moc)
    }
    
    var downloadManager = DownloadManager()
    
    // current device
    var connectedPeripheral: CBPeripheral?
    var discoveredPeripheral: CBPeripheral?
    var racpControlPointChar: CBCharacteristic?
    var racpMeasurementValueChar: CBCharacteristic?
    var racpControlPointNotifying: Bool = false
    var racpMeasurementValueNotifying: Bool = false
    var connectTimer: Timer?
}

class MyCentralManagerDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = MyCentralManagerDelegate()
    private var moc: NSManagedObjectContext!
    private var lm = LocationManager()
    private var model = BeaconModel.shared
    private var doUpdateAdv: Bool = true

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized") // TODO
            model.isBluetoothAuthorization = false
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            model.isBluetoothAuthorization = true
//            stopScanAndLocationService()
        startScanAndLocationService()
        @unknown default:
            print("central.state is @unknown default")
        }
    }
    
    func startScanAndLocationService() {
        lm.startMySignificantLocationChanges()
        MyBluetoothManager.shared.central.scanForPeripherals(withServices: nil, options: nil)
        print("startScanAndLocationService")
    }
    
    func stopScanAndLocationService() {
        lm.stopMySignificantLocationChanges()
        MyBluetoothManager.shared.central.stopScan()
        print("stopScanAndLocationService")
    }
    
    func startUpdateAdv() {
        doUpdateAdv = true
    }
    func stopUpdateAdv() {
        doUpdateAdv = false
    }

}

extension MyCentralManagerDelegate {
    
    func setMoc(moc: NSManagedObjectContext){
        if (self.moc == nil) {
            print("MyCentralManagerDelegate moc not set yet")
        }
        self.moc = moc
        print("MyCentralManagerDelegate moc set")
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
    
    func fetchAllBeacons() -> [Beacon] {
        let fetchRequest: NSFetchRequest<Beacon> = Beacon.fetchRequest()
        do {
            let beacons: [Beacon] = try MyCentralManagerDelegate.shared.moc.fetch(fetchRequest)
            return beacons
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }
        return []
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
        
        let companyId = Int16(UInt16_decode(msb: manufacturerData[1], lsb: manufacturerData[0]))
        
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
            print("beacon found maj \(0<<8 | UInt8(manufacturerData[3])) min \(UInt8(manufacturerData[4]) | UInt8(manufacturerData[5]))")
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
        //        print("temperature \(temperature), humidity \(humidity)")
        
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
                beacon.device_name = peripheral.name ?? "(no device name)"

                print(beacon)
                print("add new beacon \(peripheral.identifier)")

                guard let newadv = beacon.adv else { return }
                print("inverse \(newadv.beacon?.name ?? "inverse beacon not set")")
            }
        }
        
        beaconFind?.localTimestamp = Date()
        if !doUpdateAdv {
            return
        }
        
        if doUpdateAdv {
            if let beacon = beaconFind {
                if beacon.adv != nil {
                    // nothing
                } else {
                    beacon.adv = BeaconAdv(context: MyCentralManagerDelegate.shared.moc)
                }
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
        
        if let location = lm.location {
            //            print(location)
            if let _ = beacon.location { } else {
                beacon.location = BeaconLocation(context: MyCentralManagerDelegate.shared.moc)
            }
            guard let beaconloc = beacon.location else { return }
            beaconloc.latitude = location.latitude
            beaconloc.longitude = location.longitude
            beaconloc.timestamp = Date()
        }
        
        //        PersistenceController.shared.saveBackgroundContext(backgroundContext: MyCentralManagerDelegate.shared.moc)
        // PROFIL
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("centralManager didConnect peripheral")
        peripheral.delegate = self
        MyBluetoothManager.shared.discoveredPeripheral = peripheral
        central.stopScan()
        
        if let timer = MyBluetoothManager.shared.connectTimer {
            print("stopTimer because connected")
            timer.invalidate()
        }
        
        MyBluetoothManager.shared.connectTimer = nil
        if let downloadHistory =  MyBluetoothManager.shared.downloadManager.activeDownload {
            downloadHistory.status = .downloading_num
        }
        peripheral.discoverServices([BeaconPeripheral.beaconRemoteServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        print("centralManager didDisconnect peripheral")
        peripheral.delegate = nil
        MyBluetoothManager.shared.discoveredPeripheral = nil
//        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("peripheral didDiscoverServices")
        if let services = peripheral.services {
            print("found \(services.count) services:")
            for service in services {
                print(service)
                peripheral.discoverCharacteristics(
                    [BeaconPeripheral.beaconRACPControlPointCharUUID,
                     BeaconPeripheral.beaconRACPMeasurementValuesCharUUID], for: service)
            }
        }
        return
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("peripheral didDiscoverCharacteristicsFor service")
        if let characteristics = service.characteristics {
            if let myperipheral = MyBluetoothManager.shared.discoveredPeripheral {
                print("found \(characteristics.count) characteristics")
                for characteristic in characteristics {
                    print(characteristic)
                    if characteristic.uuid == BeaconPeripheral.beaconRACPControlPointCharUUID {
                        print("characteristic found: beaconRACPControlPointCharUUID")
                        MyBluetoothManager.shared.racpControlPointChar = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                    } else if characteristic.uuid == BeaconPeripheral.beaconRACPMeasurementValuesCharUUID {
                        print("characteristic found: beaconRACPMeasurementValuesCharUUID")
                        MyBluetoothManager.shared.racpMeasurementValueChar = characteristic
                        myperipheral.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        }
    }
    
    /*
     * We will first check if we are already connected to our counterpart
     * Otherwise, scan for peripherals - specifically for our service's 128bit CBUUID
     */
    private func retrievePeripheral() {
        
        let connectedPeripherals: [CBPeripheral] = (MyBluetoothManager.shared.central.retrieveConnectedPeripherals(withServices: [BeaconPeripheral.beaconRemoteServiceUUID]))
        
        os_log("Found connected Peripherals with transfer service: %@", connectedPeripherals)
        
        if let connectedPeripheral = connectedPeripherals.last {
            os_log("Connecting to peripheral %@", connectedPeripheral)
            MyBluetoothManager.shared.discoveredPeripheral = connectedPeripheral
            MyBluetoothManager.shared.central.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            MyBluetoothManager.shared.central.scanForPeripherals(withServices: [BeaconPeripheral.beaconRemoteServiceUUID],
                                                                 options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    /*
     *  Call this when things either go wrong, or you're done with the connection.
     *  This cancels any subscriptions if there are any, or straight disconnects if not.
     *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    private func cleanup() {
        // Don't do anything if we're not connected
        guard let discoveredPeripheral = MyBluetoothManager.shared.discoveredPeripheral,
              case .connected = discoveredPeripheral.state else { return }
        
        for service in (discoveredPeripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == BeaconPeripheral.beaconRACPControlPointCharUUID && characteristic.isNotifying {
                    discoveredPeripheral.setNotifyValue(false, for: characteristic)
                } else if characteristic.uuid == BeaconPeripheral.beaconRACPMeasurementValuesCharUUID && characteristic.isNotifying {
                    discoveredPeripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        MyBluetoothManager.shared.central.cancelPeripheralConnection(discoveredPeripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error changing notification state: %s", error.localizedDescription)
            return
        }
        
        print("peripheral didUpdateNotificationStateFor characteristic")
        
        if(characteristic.uuid == BeaconPeripheral.beaconRACPMeasurementValuesCharUUID){
            MyBluetoothManager.shared.racpMeasurementValueNotifying = characteristic.isNotifying
        } else if(characteristic.uuid == BeaconPeripheral.beaconRACPControlPointCharUUID){
            MyBluetoothManager.shared.racpControlPointNotifying = characteristic.isNotifying
        }
        
        guard let discoveredPeripheral = MyBluetoothManager.shared.discoveredPeripheral,
              let transferCharacteristic = MyBluetoothManager.shared.racpControlPointChar
        else { return }
        
        if characteristic.isNotifying {
            print("Notification began on %@", characteristic)
        } else {
            print("Notification stopped on %@. Disconnecting", characteristic)
            if !MyBluetoothManager.shared.racpMeasurementValueNotifying &&
                !MyBluetoothManager.shared.racpControlPointNotifying {
                cleanup()
            }
        }
        
        if ( MyBluetoothManager.shared.racpMeasurementValueNotifying == true) {
            if ( MyBluetoothManager.shared.racpControlPointNotifying == true) {
                let rawPacket: [UInt8] = [04, 01]   // get num
                let data = Data(rawPacket)
                if let downloadHistory = MyBluetoothManager.shared.downloadManager.activeDownload {
                    downloadHistory.history.removeAll()
                }
                discoveredPeripheral.writeValue(data, for: transferCharacteristic, type: .withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        // receivd data with [01,01]
        // encoded data 00 00 A8 3B 3F 60 60 D0 5D 10
        // ...
        // encoded data 08 00 07 45 3F 60 61 2A 5E 65
        // encoded data 06 00 01 01
        // Done received value 9, control 1
        // beaconHistory.count 9
        
        // receivd data with [04,01]
        // encoded data 05 00 02 00
        // Done received value 0, control 1
        // beaconHistory.count 0
        
        guard let characteristicData = characteristic.value else { return }
//        let encodedData =
//            (characteristicData.hexEncodedString(options: .upperCase) as String).group(by: 2, separator: " ")
        //        print("encoded data \(encodedData)")
    
        let downloadManager = MyBluetoothManager.shared.downloadManager
        if characteristic.uuid == BeaconPeripheral.beaconRACPMeasurementValuesCharUUID {
//            downloadManager.counterMeasurementValueNotification += 1
            let seqNumber = UInt16_decode(msb: characteristicData[1], lsb: characteristicData[0])
            let epochTime = UInt32_decode(msb1: characteristicData[5],msb0: characteristicData[4], lsb1: characteristicData[3], lsb0: characteristicData[2])
            let temperature = getSHT3temperatureValue(msb: characteristicData[6], lsb: characteristicData[7])
            let humidity = getSHT3humidityValue(msb: characteristicData[8], lsb: characteristicData[9])
            
            let dataPoint = BeaconHistoryDataPointLocal(
                sequenceNumber: seqNumber, humidity: humidity, temperature: temperature,
                timestamp: NSDate(timeIntervalSince1970: TimeInterval(epochTime)) as Date)
            
            if let download = downloadManager.activeDownload {
                download.history.append(dataPoint)
                download.numEntriesReceived += 1
                download.progress = Float(download.numEntriesReceived) / Float(download.numEntriesAll)
            }
        }
        
        if characteristic.uuid == BeaconPeripheral.beaconRACPControlPointCharUUID {
//            MyBluetoothManager.shared.counterControlPointNotification += 1
            
            if (characteristicData[0] == 5) && (characteristicData[1] == 0) {
                let historyCount = UInt16_decode(msb: characteristicData[3] , lsb: characteristicData[2] )
                print("number of history points \(historyCount)")
                
                if let downloadHistory = MyBluetoothManager.shared.downloadManager.activeDownload {
                    downloadHistory.status = .downloading_data
                    downloadHistory.numEntriesAll = Int(historyCount)
//                    downloadHistory.numEntriesReceived = 0
                }
                
                guard let discoveredPeripheral = MyBluetoothManager.shared.discoveredPeripheral,
                      let transferCharacteristic = MyBluetoothManager.shared.racpControlPointChar
                else { return }
                let rawPacket: [UInt8] = [01, 01]   // get all
                let data = Data(rawPacket)
                discoveredPeripheral.writeValue(data, for: transferCharacteristic, type: .withResponse)
            } else {
                if let downloadHistory = MyBluetoothManager.shared.downloadManager.activeDownload {
//                    print("Done received value \(MyBluetoothManager.shared.counterMeasurementValueNotification), control \(MyBluetoothManager.shared.counterControlPointNotification)")
                    print("beaconHistory.count \(downloadHistory.history.count)")
                    print("cleanup called")
                    downloadHistory.status = .downloading_finished
                    
                    if let connectto = MyBluetoothManager.shared.connectedPeripheral {
                        MyBluetoothManager.shared.downloadManager.mergeHistoryToStore(uuid: connectto.identifier)
                    }
                    
                    cleanup()
                    downloadManager.status = .idle
                    downloadManager.resume()
                }
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            if let error = error {
                print("Failed didWriteValueFor to %@. %s", peripheral, String(describing: error))
            }
            print ("didWriteValueFor called")
        }
        
        
    }
    
}
