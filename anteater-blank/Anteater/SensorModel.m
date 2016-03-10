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
    char type;
    NSMutableString *payload;
}


-(id)init {
    NSLog(@"init");
    self = [super init];
    if (self) {
        _sensorReadings = [[NSMutableArray alloc] init];
        cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        p = nil;
        shouldScan = FALSE;
        type = 'X';         // Use X as a sentinel for no type.
        payload = [[NSMutableString alloc] init];
    }

    return self;
}


-(void)startScanning {
    NSLog(@"startScanning");
    shouldScan = TRUE;
    [self scanForPeripherals];
}


-(void)stopScanning {
    NSLog(@"stopScanning");
    shouldScan = FALSE;
    [cm stopScan];
    [_delegate bleDidDisconnect];
    p = nil;
}


-(BOOL)isConnected {
    return p != nil;
}


-(void)scanForPeripherals {
    if (cm.state == CBCentralManagerStatePoweredOn && shouldScan) {
        [cm
            scanForPeripheralsWithServices: @[[CBUUID UUIDWithString:@RBL_SERVICE_UUID]]
            options:nil
        ];
    }
}


-(NSString *)currentSensorId {
    NSString *name = @"No anthill connected";
    if (p) {
        name = p.name;
    }

    return name;
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
    [self scanForPeripherals];
}


- (void)centralManager:(CBCentralManager *)central
        didDiscoverPeripheral:(CBPeripheral *)peripheral
        advertisementData:(NSDictionary<NSString *, id> *)advertisementData
        RSSI:(NSNumber *)RSSI {
    NSLog(@"didDiscoverPeripheral");
    p = peripheral;
    p.delegate = self;
    [cm connectPeripheral:p options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES}];
}


- (void)centralManager:(CBCentralManager *)central
        didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral");
    [_delegate bleDidConnect];
    [p discoverServices:nil];
}


- (void)centralManager:(CBCentralManager *)central
        didDisconnectPeripheral:(CBPeripheral *)peripheral
        error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral");
    p = nil;
    [_delegate bleDidDisconnect];

    // Find a better way to do this.
    [self startScanning];
}


#pragma mark Peripheral Delegate Functions

- (void)peripheral:(CBPeripheral *)peripheral
        didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices");
    for (CBService *s in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:s];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral
        didDiscoverCharacteristicsForService:(CBService *)service
        error:(NSError *)error {
    NSLog(@"didDiscoverCharacteristicsForService");
    if ([[[service UUID] UUIDString] isEqualToString:@RBL_SERVICE_UUID]) {
        for (CBCharacteristic *c in service.characteristics) {
            if ([[[c UUID] UUIDString] isEqualToString:@RBL_CHAR_TX_UUID]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral
        didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
        error:(NSError *)error {
    NSLog(@"didUpdateValueForCharacteristic");

    char data[20];
    unsigned long data_len = MIN(20,characteristic.value.length);
    [characteristic.value getBytes:data length:data_len];

    for (int i = 0; i < data_len; i++) {
        if (type == 'X') {
            // We expect the first character to be a message type, but the
            // central (iPhone) sometimes receives an intermediate message
            // after connecting to the peripheral (anthill). Specifically,
            // the central may receive the second or third packet in a message,
            // missing the type identifier in the first.
            NSLog(@"Intermediate message received.");

            // Skip over the data in the beginning of the message to find the
            // start of the next message.
            while (i < data_len &&
                   data[i] != 'H' &&
                   data[i] != 'T' &&
                   data[i] != 'E') {
                i++;
            }

            if (i < data_len) {
                type = data[i];
            }
        } else if (type == 'H' || type == 'T') {
            int start = i;
            while (i < data_len && data[i] != 'D') {
                i++;
            }

            // Write to the payload regardless of whether the message is
            // completed, unless 'D' is the first character in the packet.
            // In that case, there is no data to write and the current content
            // of the buffer is the complete message.
            if (i > 0) {
                NSData* d = [NSData dataWithBytes:data length:data_len];
                [payload
                    appendString: [
                        [[NSString alloc]
                            initWithData:d
                            encoding:NSUTF8StringEncoding
                        ]
                        substringWithRange:NSMakeRange(start, i - start)
                    ]
                ];
            }

            // If the message is completed, add the new records to the sensor
            // readings array and reset the buffer.
            if (i < data_len) {
                SensorReadingType t =
                    type == 'H' ? kHumidityReading : kTemperatureReading;
                BLESensorReading *reading = [
                    [BLESensorReading alloc]
                        initWithReadingValue:[payload floatValue]
                        andType:t
                        atTime:[NSDate date]
                        andSensorId:[self currentSensorId]
                ];

                [_sensorReadings addObject:reading];
                [_delegate bleGotSensorReading:reading];
                [AnteaterREST
                    postListOfSensorReadings:@[reading]
                    andCallCallback:NULL
                ];

                type = 'X';
                [payload setString:@""];
            }
        } else {
            NSLog(@"Error message received: %c", data[i]);
            type = 'X';
        }
    }
}


@end
