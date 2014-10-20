//
//  Pinger.m
//  Network Monitor
//
//  Created by HCorbucc on 10/14/14.
//  Copyright (c) 2014 Hugo Corbucci. All rights reserved.
//

#import "Pinger.h"

@implementation Pinger
- (id)initWatching:(id)ipAddress withTimeout:(id)timeout {
    _ipAddress = ipAddress;
    _timeout = timeout;
    return [super init];
}

- (BOOL)ping {
    NSLog(@"%@", self);
    NSTask *pingTask = [[NSTask alloc] init];
    [pingTask setLaunchPath: @"/sbin/ping"];
    [pingTask setArguments: @[
                               [NSString stringWithFormat: @"-t%@", _timeout],
                               @"-o",
                               [NSString stringWithFormat: @"%@", _ipAddress]
                            ]];
    [pingTask launch];
    [pingTask waitUntilExit];
    return [pingTask terminationStatus] == 0;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"ping -t%@ -o %@", _timeout, _ipAddress];
}

@end