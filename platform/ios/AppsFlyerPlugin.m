#import "AppsFlyerPlugin.h"
#import "AppsFlyerTracker.h"

@implementation AppsFlyerPlugin

@synthesize callbackId;

- (CDVPlugin *)initWithWebView:(UIWebView *)theWebView
{
    self = (AppsFlyerPlugin *)[super initWithWebView:theWebView];
    return self;
}

- (void)initSdk:(CDVInvokedUrlCommand*)command
{
    if ([command.arguments count] < 2) {
        return;
    }
    
    self.callbackId = command.callbackId;
    
    [self.commandDelegate runInBackground:^{
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        // leave communication channel open with keepcallback
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
    
    NSString* devKey = [command.arguments objectAtIndex:0];
    NSString* appId = [command.arguments objectAtIndex:1];
    
    
    [AppsFlyerTracker sharedTracker].appleAppID = appId;
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = devKey;
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    [self performSelector:@selector(initDelegate) withObject:nil afterDelay:7];
}

- (void) initDelegate{
    [AppsFlyerTracker sharedTracker].delegate = self;
}

- (void)setCurrencyCode:(CDVInvokedUrlCommand*)command
{
    if ([command.arguments count] == 0) {
        return;
    }
    
    NSString* currencyId = [command.arguments objectAtIndex:0];
    [AppsFlyerTracker sharedTracker].currencyCode = currencyId;
}

- (void)setAppUserId:(CDVInvokedUrlCommand *)command
{
    if ([command.arguments count] == 0) {
        return;
    }
    
    NSString* userId = [command.arguments objectAtIndex:0];
    [AppsFlyerTracker sharedTracker].customerUserID  = userId;
}

- (void)getAppsFlyerUID:(CDVInvokedUrlCommand *)command
{
    NSString* userId = [[AppsFlyerTracker sharedTracker] getAppsFlyerUID];
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                    resultWithStatus    : CDVCommandStatus_OK
                                    messageAsString: userId
                                    ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendTrackingWithEvent:(CDVInvokedUrlCommand *)command
{
    if ([command.arguments count] < 2) {
        return;
    }
    
    NSString* eventName = [command.arguments objectAtIndex:0];
    NSString* eventValue = [command.arguments objectAtIndex:1];
    [[AppsFlyerTracker sharedTracker] trackEvent:eventName withValue:eventValue];
}

-(void)onConversionDataReceived:(NSDictionary*) installData {
    
    if (self.callbackId) {
        NSLog(@"[AppsFlyer Plugin] onConversionDataReceived: sending plugin result");
        
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:installData];
        [result setKeepCallback:[NSNumber numberWithBool:YES]];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
    else {
        NSLog(@"[AppsFlyer Plugin] onConversionDataReceived: Error self.callbackId empty");
    }
}

-(void)onConversionDataRequestFailure:(NSError *) error {
    
    NSString *errorMessage = [error localizedDescription];
    NSLog(@"[AppsFlyer Plugin] onConversionDataRequestFailure: %@", [error localizedDescription]);
    
    if (self.callbackId) {
        NSLog(@"[AppsFlyer Plugin] onConversionDataRequestFailure: sending error");
        
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
        [self.commandDelegate sendPluginResult:commandResult callbackId:self.callbackId];
    }
    else {
        NSLog(@"[AppsFlyer Plugin] onConversionDataRequestFailure: Error self.callbackId empty");
    }
}

@end
