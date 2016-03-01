//
//  BLEMananger.m
//  Anteater
//
//  Created by Sam Madden on 1/13/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import "SensorModel.h"
#import "AnteaterREST.h"
#import "SettingsModel.h"

#import <CoreBluetooth/CoreBluetooth.h>

#define RBL_SERVICE_UUID "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_TX_UUID "713D0002-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_RX_UUID "713D0003-503E-4C75-BA94-3148F18D941E"

static id _instance;
@implementation SensorModel {
    CBCentralManager *cm;
    CBPeripheral *p;
    BOOL shouldScan;
}


-(id)init {
    NSLog(@"init");
    self = [super init];
    if (self) {
        cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        shouldScan = FALSE;
    }
    return self;
}


-(void)startScanning {
    NSLog(@"startScanning");
    shouldScan = TRUE;
}


-(void)stopScanning {
    NSLog(@"stopScanning");
    shouldScan = FALSE;
    [cm stopScan];
    [_delegate bleDidDisconnect];
    p = nil;
}


-(BOOL)isConnected {
    return shouldScan;
}


-(NSString *)currentSensorId {
    return p.name;
}


+(SensorModel *) instance {
    if (!_instance) {
        _instance = [[SensorModel alloc] init];
    }
    return _instance;
}


#pragma mark Central Manager Delegate Functions

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"centralManagerDidUpdateState");
    if (cm.state == CBCentralManagerStatePoweredOn && shouldScan) {
        [cm
            scanForPeripheralsWithServices:
                [NSArray arrayWithObject:
                    [CBUUID UUIDWithString:@RBL_CHAR_RX_UUID]]
            options:nil
        ];
    }
}


- (void)centralManager:(CBCentralManager *)central
        didDiscoverPeripheral:(CBPeripheral *)peripheral
        advertisementData:(NSDictionary<NSString *, id> *)advertisementData
        RSSI:(NSNumber *)RSSI {
    NSLog(@"didDiscoverPeripheral");
    p = peripheral;
    p.delegate = self;
    [cm
        connectPeripheral:p
        options:
            [NSDictionary
                dictionaryWithObject:[NSNumber numberWithBool:YES]
                forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey
            ]
    ];
}


- (void)centralManager:(CBCentralManager *)central
        didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral");
    [p discoverServices:nil];
    [_delegate bleDidConnect];
}


#pragma mark Peripheral Delegate Functions

- (void)peripheral:(CBPeripheral *)peripheral
        didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices");
    for (CBService *s in peripheral.services)
    {
        [peripheral discoverCharacteristics:nil forService:s];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral
        didDiscoverCharacteristicsForService:(CBService *)service
        error:(NSError *)error {
    if ([[[service UUID] UUIDString] isEqualToString:@RBL_SERVICE_UUID]) {
        for (CBCharacteristic *c in service.characteristics) {
            if ([[[c UUID] UUIDString] isEqualToString:@RBL_CHAR_TX_UUID]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }
        }
    }
}


// TODO: implement
- (void)peripheral:(CBPeripheral *)peripheral
        didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
        error:(NSError *)error {
    
}


@end
