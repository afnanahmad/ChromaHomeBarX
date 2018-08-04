#include "ACXRootListController.h"
#define chromahomebarxPrefs @"/var/mobile/Library/Preferences/com.afnan.chromahomebarxpref.plist"

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

@end