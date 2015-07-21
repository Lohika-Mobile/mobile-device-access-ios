//
//  DeviceAccessManager.m
//  DeviceAccessTool
//
//  Created by Alexander Trishyn on 7/21/15.
//  Copyright (c) 2015 Lohika. The MIT License (MIT).
//

#import "DeviceAccessManager.h"

@interface DeviceAccessManager()<MobileDeviceAccessListener>
@property (nonatomic, readwrite) NSMutableArray* devices;
@end

#pragma mark-

@implementation DeviceAccessManager

- (id)init {
    if ((self = [super init])) {
        self.devices = [NSMutableArray new];
        [[MobileDeviceAccess singleton] setListener:self];
    }
    return self;
}

#pragma mark-

- (void)deviceConnected:(AMDevice*)device
{
    [self.devices addObject:device];
}

- (void)deviceDisconnected:(AMDevice*)device
{
    [self.devices removeObject:device];
}

@end
