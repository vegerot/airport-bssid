#!/usr/bin/env swift
//
//  main.swift
//  airport-bssid
//
//  Created by Max Coplan on 11/23/19.
//  Copyright © 2019 Shintaro Tanaka. All rights reserved.
//

import Foundation

import CoreWLAN

enum OutputType {
    case error
    case standard
}

func dump_error(message: String)
{
    print(message+"\n")
    exit(1)
}

func phyModeName(n: CWPHYMode)-> String
{
    switch(n)
    {
    case CWPHYMode.modeNone: return "none";
    case CWPHYMode.mode11n: return "802.11n";
    case CWPHYMode.mode11a: return "802.11a";
    case CWPHYMode.mode11ac: return "802.11ac";
    case CWPHYMode.mode11g: return "802.11g";
    case CWPHYMode.mode11b: return "802.11b";
    default: return "other/unknown";
    }
    
}

func writeMessage(_ message: String, to: OutputType = .standard)
{
    switch to
    {
    case .standard:
        print("\(message)")
    case .error:
        fputs("Error: \(message)\n", stderr)
    }
}


func printUsage()
{
    let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
    
    dump_error(message: "usage: \(executableName) <ifname> <command>\n\nCommands:\n\tconnect [bssid] [password]\n\tscan [name] [band:2.4|5]")
    
}


func bandName(network: CWChannelBand)->String
{
    switch(network)
    {
    case .band2GHz: return "2.4"
    case .band5GHz: return "5"
    default: return "N/I"
    }
}

func doScan(interface: CWInterface, ssidName: String) -> Set<CWNetwork>
{
    let scan: Set<CWNetwork>
    do
    {
   scan = try (interface.scanForNetworks(withName: ssidName, includeHidden:true))
    } catch {
       dump_error(message: "An error has occured  while scanning networks: \(error)")
        scan=Set<CWNetwork>()
    }
    return scan
    
}
enum ansiColor: String {
case black = "\u{001B}[0;30m"
case red = "\u{001B}[0;31m"
case green = "\u{001B}[0;32m"
case yellow = "\u{001B}[0;33m"
case blue = "\u{001B}[0;34m"
case magenta = "\u{001B}[0;35m"
case cyan = "\u{001B}[0;36m"
case white = "\u{001B}[0;37m"
case reset = "\u{001B}[0;0m"
}
func printInfo(network: CWNetwork, bn: String, color: ansiColor)
{
    print(String(format: "%s%24s, %17s, %4s, %3lu, %3ld\n", color.rawValue, network.ssid!, network.bssid!, bn, network.wlanChannel!.channelNumber, network.rssiValue))
}
func main()
{
    let argc=CommandLine.arguments.count
    let argv=CommandLine.arguments
    if (argc<3){
        printUsage()
    }
    
    let interfaceName: String = argv[1]
    let command: String = argv[2]
    
    var bssid: String = ""
    var password: String = ""
    
    var ssidName: String = ""
    var band: String = ""
    
    if (command == "scan")
    {
        if (argc>3)
        {
            ssidName = argv[3]
        }
        
        if (argc>4)
        {
            band = argv[4]
        }
    } else if (command == "connect")
    {
        if (argc>3)
        {
            bssid=argv[3]
        }
        if (argc>4)
        {
            password=argv[4]
        }
    } else {printUsage()}
    
    let interface = (CWWiFiClient.init().interface(withName: interfaceName))!
    if(!interface.powerOn())
    {
        dump_error(message: "The interface is down.  Please activate the  interface before connecting to network!")
        
    }
    
    print( "Notice: The interface \(interfaceName) is in \(phyModeName(n: (interface.activePHYMode()))) phyMode.\n")
    
    // search for target bssid
    
    
    //let nameDescriptor: NSSortDescriptor = NSSortDescriptor.init(key: "ssid", ascending: true)

    let scan: Set<CWNetwork> = doScan(interface: interface, ssidName: ssidName)
    
    var targetNetwork: CWNetwork?
    
    print("***** Scanned networks *****\n")
    //print(String(format: "%24s, %17s, %4s, %3s, RSSI(dBm)\n", "ESSID", "BSSID", "Band", "Ch"))
    for network in scan
    {
        let bn: String = bandName(network: network.wlanChannel!.channelBand )
        if (band==bn)
        {
            continue
        }
        
        if (network.bssid == bssid)
        {
            targetNetwork = network
            printInfo(network: network, bn: bn, color: ansiColor.green)
        } else {
            printInfo(network: network, bn: bn, color: ansiColor.reset)
        }
    }
    
    print(ansiColor.reset.rawValue+"****************************\n")
    
    if(!bssid.isEmpty)
    {
        exit(0)
    }
    
    if(targetNetwork == nil)
    {
        dump_error(message: "The target  network \(bssid) could not be found")
    }
   do
   {
    
    let result: () = try interface.associate(to: targetNetwork!, password: password)
    print(result)
   } catch {
    dump_error(message: "Could not connect to network: \(error)")
    }
    
    print("Associated to network \(targetNetwork!.ssid!) (BSSID: \(bssid))\n")
}

main()
