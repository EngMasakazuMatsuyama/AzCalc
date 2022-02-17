//  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

import UIKit

let IFPGA_NAMESTRING = "iFPGA"

let IPHONE_1G_NAMESTRING = "iPhone 1G"
let IPHONE_3G_NAMESTRING = "iPhone 3G"
let IPHONE_3GS_NAMESTRING = "iPhone 3GS"
let IPHONE_4_NAMESTRING = "iPhone 4"
let IPHONE_5_NAMESTRING = "iPhone 4S" //@"iPhone 5"
let IPHONE_UNKNOWN_NAMESTRING = "Unknown iPhone"

let IPOD_1G_NAMESTRING = "iPod touch 1G"
let IPOD_2G_NAMESTRING = "iPod touch 2G"
let IPOD_3G_NAMESTRING = "iPod touch 3G"
let IPOD_4G_NAMESTRING = "iPod touch 4G"
let IPOD_UNKNOWN_NAMESTRING = "Unknown iPod"

let IPAD_1G_NAMESTRING = "iPad 1G"
let IPAD_2G_NAMESTRING = "iPad 2G"
let IPAD_UNKNOWN_NAMESTRING = "Unknown iPad"

// Nano? Apple TV?
let APPLETV_2G_NAMESTRING = "Apple TV 2G"

let IPOD_FAMILY_UNKNOWN_DEVICE = "Unknown iOS device"

let IPHONE_SIMULATOR_NAMESTRING = "iPhone Simulator"
let IPHONE_SIMULATOR_IPHONE_NAMESTRING = "iPhone Simulator"
let IPHONE_SIMULATOR_IPAD_NAMESTRING = "iPad Simulator"
enum UIDevicePlatform : Int {
    case uiDeviceUnknown
    case uiDeviceiPhoneSimulator
    case uiDeviceiPhoneSimulatoriPhone // both regular and iPhone 4 devices
    case uiDeviceiPhoneSimulatoriPad
    case uiDevice1GiPhone
    case uiDevice3GiPhone
    case uiDevice3GSiPhone
    case uiDevice4iPhone
    case uiDevice5iPhone
    case uiDevice1GiPod
    case uiDevice2GiPod
    case uiDevice3GiPod
    case uiDevice4GiPod
    case uiDevice1GiPad // both regular and 3G
    case uiDevice2GiPad
    case uiDeviceAppleTV2
    case uiDeviceUnknowniPhone
    case uiDeviceUnknowniPod
    case uiDeviceUnknowniPad
    case uiDeviceIFPGA
}

extension UIDevice {
    /*
     Platforms

     iFPGA ->		??

     iPhone1,1 ->	iPhone 1G
     iPhone1,2 ->	iPhone 3G
     iPhone2,1 ->	iPhone 3GS
     iPhone3,1 ->	iPhone 4/AT&T
     iPhone3,2 ->	iPhone 4/Other Carrier?
     iPhone3,3 ->	iPhone 4/Other Carrier?
     iPhone4,1 ->	??iPhone 5  <<<<<<<<< 4S

     iPod1,1   -> iPod touch 1G 
     iPod2,1   -> iPod touch 2G 
     iPod2,2   -> ??iPod touch 2.5G
     iPod3,1   -> iPod touch 3G
     iPod4,1   -> iPod touch 4G
     iPod5,1   -> ??iPod touch 5G

     iPad1,1   -> iPad 1G, WiFi
     iPad1,?   -> iPad 1G, 3G <- needs 3G owner to test
     iPad2,1   -> iPad 2G (iProd 2,1)

     AppleTV2,1 -> AppleTV 2

     i386, x86_64 -> iPhone Simulator
    */


    // MARK: sysctlbyname utils

    func getSysInfo(byName typeSpecifier: UnsafeMutablePointer<Int8>?) -> String? {
        var size: size_t
        sysctlbyname(typeSpecifier, nil, &size, nil, 0)
        let answer = malloc(size)
        sysctlbyname(typeSpecifier, answer, &size, nil, 0)
        let results = String(cString: answer, encoding: .utf8)
        free(answer)
        return results
    }

    func platform() -> String? {
        return getSysInfo(byName: UnsafeMutablePointer<Int8>(mutating: "hw.machine"))
    }

    // Thanks, Atomicbird
    func hwmodel() -> String? {
        return getSysInfo(byName: UnsafeMutablePointer<Int8>(mutating: "hw.model"))
    }

    // MARK: sysctl utils

    func getSysInfo(_ typeSpecifier: UInt) -> Int {
        var size = MemoryLayout<Int>.size
        var results: Int
        let mib = [CTL_HW, typeSpecifier]
        sysctl(mib, 2, &results, &size, nil, 0)
        return results
    }

    func cpuFrequency() -> Int {
        return getSysInfo(HW_CPU_FREQ)
    }

    func busFrequency() -> Int {
        return getSysInfo(HW_BUS_FREQ)
    }

    func totalMemory() -> Int {
        return getSysInfo(HW_PHYSMEM)
    }

    func userMemory() -> Int {
        return getSysInfo(HW_USERMEM)
    }

    func maxSocketBufferSize() -> Int {
        return getSysInfo(KIPC_MAXSOCKBUF)
    }

    // MARK: file system -- Thanks Joachim Bean!

    func totalDiskSpace() -> NSNumber? {
        var fattributes: [FileAttributeKey : Any]? = nil
        do {
            fattributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        } catch {
        }
        return fattributes?[.systemSize] as? NSNumber
    }

    func freeDiskSpace() -> NSNumber? {
        var fattributes: [FileAttributeKey : Any]? = nil
        do {
            fattributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        } catch {
        }
        return fattributes?[.systemFreeSize] as? NSNumber
    }

    // MARK: platform type and name utils

    func platformType() -> Int {
        let platform = self.platform()
        // if ([platform isEqualToString:@"XX"])			return UIDeviceUnknown;

        if platform == "iFPGA" {
            return UIDevicePlatform.uiDeviceIFPGA.rawValue
        }

        if platform == "iPhone1,1" {
            return UIDevicePlatform.uiDevice1GiPhone.rawValue
        }
        if platform == "iPhone1,2" {
            return UIDevicePlatform.uiDevice3GiPhone.rawValue
        }
        if platform?.hasPrefix("iPhone2") ?? false {
            return UIDevicePlatform.uiDevice3GSiPhone.rawValue
        }
        if platform?.hasPrefix("iPhone3") ?? false {
            return UIDevicePlatform.uiDevice4iPhone.rawValue
        }
        if platform?.hasPrefix("iPhone4") ?? false {
            return UIDevicePlatform.uiDevice5iPhone.rawValue
        }

        if platform == "iPod1,1" {
            return UIDevicePlatform.uiDevice1GiPod.rawValue
        }
        if platform == "iPod2,1" {
            return UIDevicePlatform.uiDevice2GiPod.rawValue
        }
        if platform == "iPod3,1" {
            return UIDevicePlatform.uiDevice3GiPod.rawValue
        }
        if platform == "iPod4,1" {
            return UIDevicePlatform.uiDevice4GiPod.rawValue
        }

        if platform == "iPad1,1" {
            return UIDevicePlatform.uiDevice1GiPad.rawValue
        }
        if platform == "iPad2,1" {
            return UIDevicePlatform.uiDevice2GiPad.rawValue
        }

        if platform == "AppleTV2,1" {
            return UIDevicePlatform.uiDeviceAppleTV2.rawValue
        }

        /*
        	 MISSING A SOLUTION HERE TO DATE TO DIFFERENTIATE iPAD and iPAD 3G.... SORRY!
        	 */

        if platform?.hasPrefix("iPhone") ?? false {
            return UIDevicePlatform.uiDeviceUnknowniPhone.rawValue
        }
        if platform?.hasPrefix("iPod") ?? false {
            return UIDevicePlatform.uiDeviceUnknowniPod.rawValue
        }
        if platform?.hasPrefix("iPad") ?? false {
            return UIDevicePlatform.uiDeviceUnknowniPad.rawValue
        }

        if platform?.hasSuffix("86") ?? false || (platform == "x86_64") {
            if UIScreen.main.bounds.size.width < 768 {
                return UIDevicePlatform.uiDeviceiPhoneSimulatoriPhone.rawValue
            } else {
                return UIDevicePlatform.uiDeviceiPhoneSimulatoriPad.rawValue
            }

            return UIDevicePlatform.uiDeviceiPhoneSimulator.rawValue
        }
        return UIDevicePlatform.uiDeviceUnknown.rawValue
    }

    func platformString() -> String? {
        switch platformType() {
        case UIDevicePlatform.uiDevice1GiPhone.rawValue:
            return IPHONE_1G_NAMESTRING
        case UIDevicePlatform.uiDevice3GiPhone.rawValue:
            return IPHONE_3G_NAMESTRING
        case UIDevicePlatform.uiDevice3GSiPhone.rawValue:
            return IPHONE_3GS_NAMESTRING
        case UIDevicePlatform.uiDevice4iPhone.rawValue:
            return IPHONE_4_NAMESTRING
        case UIDevicePlatform.uiDevice5iPhone.rawValue:
            return IPHONE_5_NAMESTRING
        case UIDevicePlatform.uiDeviceUnknowniPhone.rawValue:
            return IPHONE_UNKNOWN_NAMESTRING
        case UIDevicePlatform.uiDevice1GiPod.rawValue:
            return IPOD_1G_NAMESTRING
        case UIDevicePlatform.uiDevice2GiPod.rawValue:
            return IPOD_2G_NAMESTRING
        case UIDevicePlatform.uiDevice3GiPod.rawValue:
            return IPOD_3G_NAMESTRING
        case UIDevicePlatform.uiDevice4GiPod.rawValue:
            return IPOD_4G_NAMESTRING
        case UIDevicePlatform.uiDeviceUnknowniPod.rawValue:
            return IPOD_UNKNOWN_NAMESTRING
        case UIDevicePlatform.uiDevice1GiPad.rawValue:
            return IPAD_1G_NAMESTRING
        case UIDevicePlatform.uiDevice2GiPad.rawValue:
            return IPAD_2G_NAMESTRING
        case UIDevicePlatform.uiDeviceAppleTV2.rawValue:
            return APPLETV_2G_NAMESTRING
        case UIDevicePlatform.uiDeviceiPhoneSimulator.rawValue:
            return IPHONE_SIMULATOR_NAMESTRING
        case UIDevicePlatform.uiDeviceiPhoneSimulatoriPhone.rawValue:
            return IPHONE_SIMULATOR_IPHONE_NAMESTRING
        case UIDevicePlatform.uiDeviceiPhoneSimulatoriPad.rawValue:
            return IPHONE_SIMULATOR_IPAD_NAMESTRING
        case UIDevicePlatform.uiDeviceIFPGA.rawValue:
            return IFPGA_NAMESTRING
        default:
            return IPOD_FAMILY_UNKNOWN_DEVICE
        }
    }

    // MARK: MAC addy
    // Return the local MAC addy
    // Courtesy of FreeBSD hackers email list
    // Accidentally munged during previous update. Fixed thanks to mlamb.
    func macaddress() -> String? {
        let mib = [Int](repeating: 0, count: 6)
        var len: size_t
        var buf: UnsafeMutablePointer<Int8>?
        var ptr: UnsafeMutablePointer<UInt8>?
        var ifm: if_msghdr?
        var sdl: sockaddr_dl?

        mib[0] = CTL_NET
        mib[1] = AF_ROUTE
        mib[2] = 0
        mib[3] = AF_LINK
        mib[4] = NET_RT_IFLIST

        if (mib[5] = if_nametoindex("en0")) == 0 {
            print("Error: if_nametoindex error\n")
            return nil
        }

        if sysctl(mib, 6, nil, &len, nil, 0) < 0 {
            print("Error: sysctl, take 1\n")
            return nil
        }

        if (buf = malloc(len)) == nil {
            print("Could not allocate memory. error!\n")
            return nil
        }

        if sysctl(mib, 6, buf, &len, nil, 0) < 0 {
            print("Error: sysctl, take 2")
            return nil
        }

        ifm = buf as? if_msghdr
        sdl = (ifm + 1) as? sockaddr_dl
        ptr = UnsafeMutablePointer<UInt8>(mutating: UInt8(LLADDR(sdl)))
        // NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
        var outstring: String? = nil
        if let ptr = ptr {
            outstring = String(format: "%02x%02x%02x%02x%02x%02x", ptr, Int(ptr ?? 0) + 1, Int(ptr ?? 0) + 2, Int(ptr ?? 0) + 3, Int(ptr ?? 0) + 4, Int(ptr ?? 0) + 5)
        }
        free(buf)
        return outstring?.uppercased()
    }

    func platformCode() -> String? {
        switch platformType() {
        case UIDevicePlatform.uiDevice1GiPhone.rawValue:
            return "M68"
        case UIDevicePlatform.uiDevice3GiPhone.rawValue:
            return "N82"
        case UIDevicePlatform.uiDevice3GSiPhone.rawValue:
            return "N88"
        case UIDevicePlatform.uiDevice4iPhone.rawValue:
            return "N89"
        case UIDevicePlatform.uiDevice5iPhone.rawValue:
            return IPHONE_UNKNOWN_NAMESTRING
        case UIDevicePlatform.uiDeviceUnknowniPhone.rawValue:
            return IPHONE_UNKNOWN_NAMESTRING
        case UIDevicePlatform.uiDevice1GiPod.rawValue:
            return "N45"
        case UIDevicePlatform.uiDevice2GiPod.rawValue:
            return "N72"
        case UIDevicePlatform.uiDevice3GiPod.rawValue:
            return "N18"
        case UIDevicePlatform.uiDevice4GiPod.rawValue:
            return "N80"
        case UIDevicePlatform.uiDeviceUnknowniPod.rawValue:
            return IPOD_UNKNOWN_NAMESTRING
        case UIDevicePlatform.uiDevice1GiPad.rawValue:
            return "K48"
        case UIDevicePlatform.uiDevice2GiPad.rawValue:
            return IPAD_UNKNOWN_NAMESTRING
        case UIDevicePlatform.uiDeviceUnknowniPad.rawValue:
            return IPAD_UNKNOWN_NAMESTRING
        case UIDevicePlatform.uiDeviceAppleTV2.rawValue:
            return "K66"
        case UIDevicePlatform.uiDeviceiPhoneSimulator.rawValue:
            return IPHONE_SIMULATOR_NAMESTRING
        default:
            return IPOD_FAMILY_UNKNOWN_DEVICE
        }
    }
    // Illicit Bluetooth check -- cannot be used in App Store
    /* 
    Class  btclass = NSClassFromString(@"GKBluetoothSupport");
    if ([btclass respondsToSelector:@selector(bluetoothStatus)])
    {
    	printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
    	bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
    	printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
    }
    */
}