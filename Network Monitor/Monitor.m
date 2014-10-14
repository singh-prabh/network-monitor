//
//  Monitor.m
//  Network Monitor
//
//  Created by HCorbucc on 10/13/14.
//  Copyright (c) 2014 Hugo Corbucci. All rights reserved.
//

#import "Monitor.h"
#import "Speaker.h"
#import "Notifier.h"
#import "Logger.h"

@interface Monitor () {
    @private
    NSDictionary *_messages;
    NSNumber *_sleepInterval;
}

@end

@implementation Monitor
NSString *const CONNECTED = @"connected";
NSString *const UNKNOWN = @"unknown";
NSString *const DISCONNECTED = @"disconnected";
NSString *const SOUND_NAME = @"Sound alerts";
NSString *const NOTIFICATION_NAME = @"Notifications";
NSString *const LOGGER_NAME = @"Logs";

- (id)initWatching:(NSString *)ipAddress andUpdating:(NSStatusItem *)item {
    NSNumber *timeout = @5;
    _sleepInterval = @5;
    _pinger = [[Pinger alloc] initWatching:ipAddress withTimeout:timeout];
    _background = [[NSThread alloc] initWithTarget:self selector:@selector(monitor) object:nil];
    _alerts = @{
        SOUND_NAME : [[Speaker alloc] init],
        NOTIFICATION_NAME : [[Notifier alloc] init],
        LOGGER_NAME : [[Logger alloc] init]
    };
    _enabledAlerts = [NSMutableDictionary dictionaryWithDictionary: @{
        SOUND_NAME: _alerts[SOUND_NAME],
        NOTIFICATION_NAME: _alerts[NOTIFICATION_NAME],
        LOGGER_NAME : _alerts[LOGGER_NAME]
        }];
    _messages = @{
                  CONNECTED : @"You are connected to the Internet.",
                  DISCONNECTED : @"You are NOT connected to the Internet.",
                  UNKNOWN: @"Your connection state is unknown."
    };
    _itemToUpdate = item;
    
    [self updateItemToState: UNKNOWN];
    return [super init];
}

- (void)start {
    [_background start];
}
- (void) setNotificationsEnabled: (BOOL) enabled {
    [self setAlertNamed: NOTIFICATION_NAME as: enabled];
}
- (void) setSoundAlertsEnabled: (BOOL) enabled {
    [self setAlertNamed: SOUND_NAME as: enabled];
}

# pragma private

- (void) setAlertNamed: (NSString*) alertName as: (BOOL) status {
    if (status) {
        _enabledAlerts[alertName] = _alerts[alertName];
    } else {
        [_enabledAlerts removeObjectForKey: alertName];
    }
    NSLog(@"%@ are now %@", alertName, _enabledAlerts[alertName] ? @"disabled" : @"enabled");
}

- (void) monitor {
    while (true)
    {
        BOOL successful = [_pinger ping];
        NSString *state = successful ? CONNECTED : DISCONNECTED;
        if ([self updateItemToState:state]) {
            for (id alertName in _enabledAlerts) {
                [_alerts[alertName] announce: _messages[state]];
            }
        }
        [NSThread sleepForTimeInterval: [_sleepInterval doubleValue]];
    }
}

- (BOOL) updateItemToState: (NSString*) state {
    NSImage *desired = [NSImage imageNamed: state];
    if (_itemToUpdate.image != desired) {
        [_itemToUpdate setImage: desired];
        [_itemToUpdate setToolTip: _messages[state]];
         return true;
     } else {
         return false;
     }
}

@end