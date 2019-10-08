//
//  main.m
//  airport-bssid
//
//  Created by Shintaro Tanaka on 6/11/13.
//  Copyright (c) 2013 Shintaro Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreWLAN/CoreWLAN.h>

NSString *usage_string(NSString *arg0) {
    return [NSString stringWithFormat:@"usage: %@ <ifname> <command>\n\nCommands:\n\tconnect [bssid] [password]\n\tscan [name] [band:2.4|5]", arg0];
}

void dump_error(NSString *message) {
    printf("%s\n", [message cStringUsingEncoding:NSUTF8StringEncoding]);
    exit(1);
}

char const *phyModeName( enum CWPHYMode n )
{
    switch( (int)n ) {
        case kCWPHYModeNone: return "none";
        case kCWPHYMode11n: return "802.11n";
        case kCWPHYMode11a: return "802.11a";
        case kCWPHYMode11ac: return "802.11ac";
        case kCWPHYMode11g: return "802.11g";
        case kCWPHYMode11b: return "802.11b";
        default: return "other/unknown";
            
    }
}

char const *bandName(enum CWChannelBand n) {
    switch ((int)n) {
        case kCWChannelBand2GHz: return "2.4";
        case kCWChannelBand5GHz: return "5";
        default: return "N/I";
    }
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        /**
         * Plan of improvement
         *
         * <<argument handling>>
         * -h, --help: show help
         * -i, --interactive: scan and assoc in interactive way
         * -s, --scan: scan only
         * -k, --use-keychain: let this use keychain on mac. This allows you to omit password input
         *
         * <<help screen>>
         *
         * <<interactive assoc>>
         *
         * <<keychain access>>
         */
        
        // args check and initialization
        if (argc < 3) dump_error(usage_string([NSString stringWithUTF8String:argv[0]]));
        NSString *interfaceName = [NSString stringWithUTF8String:argv[1]];
        NSString *command = [NSString stringWithUTF8String:argv[2]];
        
        NSString *bssid = nil;
        NSString *password = nil;
        
        NSString *ssidName = nil;
        NSString *band = nil;
    
        if ([command isEqualToString:@"scan"]) {
            if (argc > 3) {
                ssidName = [NSString stringWithUTF8String:argv[3]];
            }
            if (argc > 4) {
                band = [NSString stringWithUTF8String:argv[4]];
            }
        } else if ([command isEqualToString:@"connect"]) {
            if (argc > 3) {
                bssid = [NSString stringWithUTF8String:argv[3]];
            }
            if (argc > 4) {
                password = [NSString stringWithUTF8String:argv[4]];
            }
        } else dump_error(usage_string([NSString stringWithUTF8String:argv[0]]));
        
        // interface check
        CWInterface *interface = [[[CWWiFiClient alloc] init] interfaceWithName:interfaceName];
        if(interface.powerOn == NO )
            dump_error(@"The interface is down. Please activate the interface before connecting to network!");
        
        printf("Notice: The interface %s is in %s phyMode.\n", [interfaceName cStringUsingEncoding:NSUTF8StringEncoding], phyModeName(interface.activePHYMode));

        // search for target bssid
        NSError *error = nil;
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ssid" ascending:YES];
        NSArray *scan = [[interface scanForNetworksWithName:ssidName includeHidden:true error:&error] sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
        if (error)
            dump_error([NSString stringWithFormat:@"An error has been occurred while scanning networks: %@", error]);
        CWNetwork *targetNetwork = nil;
        
        printf("\x1B[0m***** Scanned networks *****\n");
        printf("%24s, %17s, %4s, %3s, RSSI(dBm)\n", "ESSID", "BSSID", "Band", "Ch");
        for (CWNetwork *network in scan) {
            const char * bn = bandName(network.wlanChannel.channelBand);
            if (band != nil) {
                if (![band isEqualToString:[NSString stringWithUTF8String:bn]]) continue;
            }
            if ([network.bssid isEqualToString:bssid]) {
                targetNetwork = network;
                printf("%s%24s, %17s, %4s, %3lu, %3ld\n", "\x1B[32m", [network.ssid cStringUsingEncoding:NSUTF8StringEncoding], [network.bssid cStringUsingEncoding:NSUTF8StringEncoding], bn, (unsigned long)network.wlanChannel.channelNumber, (long)network.rssiValue);
            } else {
                printf("%s%24s, %17s, %4s, %3lu, %3ld\n", "\x1B[0m", [network.ssid cStringUsingEncoding:NSUTF8StringEncoding], [network.bssid cStringUsingEncoding:NSUTF8StringEncoding], bn, (unsigned long)network.wlanChannel.channelNumber, (long)network.rssiValue);
            }
        }
        printf("\x1B[0m****************************\n");

        if (bssid == nil) {
            exit(0);
        }

        if (targetNetwork == nil)
            dump_error([NSString stringWithFormat:@"The target network \"%@\" could not be found.", bssid]);
        
        // connection trial
        BOOL result = [interface associateToNetwork:targetNetwork password:password error:&error];
        
        if (error)
            dump_error([NSString stringWithFormat:@"Could not connect to the network: %@", error]);
        
        if( !result )
			dump_error(@"Could not connect to the network!");
        
        printf("Associated to network \"%s\" (BSSID: %s)\n", [targetNetwork.ssid cStringUsingEncoding:NSUTF8StringEncoding], [bssid cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    return 0;
}

