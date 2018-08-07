#include "ACXRootListController.h"
#define chromahomebarxPrefs @"/var/mobile/Library/Preferences/com.afnanahmad.chromahomebarxpref.plist"

@implementation ACXRootListController

-(id)readPreferenceValue:(PSSpecifier *)specifier {
    NSDictionary *POSettings = [NSDictionary dictionaryWithContentsOfFile:chromahomebarxPrefs];

    if(!POSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return POSettings[specifier.properties[@"key"]];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*) specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:chromahomebarxPrefs]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:chromahomebarxPrefs atomically:YES];
    CFStringRef CPPost = (CFStringRef)CFBridgingRetain(specifier.properties[@"PostNotification"]);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CPPost, NULL, NULL, YES);
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

-(void)respring{
    pid_t respringID;
    char *argv[] = {"/usr/bin/killall", "backboardd", NULL};
    posix_spawn(&respringID, argv[0], NULL, NULL, argv, NULL);
    waitpid(respringID, NULL, WEXITED);
}

-(void)goToTwitter{
    NSString *user = @"rockafnan";
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];

}

-(void)goToPaypal{
  NSString *urlString = @"https://www.paypal.me/AfnanAhmad";
  if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]){
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
  }
}

-(void)goToHomeGesture{
  NSString *urlString = @"https://repo.packix.com/package/com.vitataf.homegesture/";
  if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]){
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
  }
}

@end
