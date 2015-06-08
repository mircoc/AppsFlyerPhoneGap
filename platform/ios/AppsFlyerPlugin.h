#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "AppsFlyerTracker.h"


@interface AppsFlyerPlugin : CDVPlugin <UIApplicationDelegate, AppsFlyerTrackerDelegate> {
    NSString *callbackId;
}

@property (nonatomic, copy) NSString *callbackId;

- (void)setCurrencyCode:(CDVInvokedUrlCommand*)command;
- (void)setAppUserId:(CDVInvokedUrlCommand*)command;
- (void)getAppsFlyerUID:(CDVInvokedUrlCommand*)command;
- (void)sendTrackingWithEvent:(CDVInvokedUrlCommand*)command;
- (void)onConversionDataReceived:(NSDictionary*) installData;
- (void)onConversionDataRequestFailure:(NSError *) error;
@end