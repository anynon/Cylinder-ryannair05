/*
Copyright (C) 2014 Reed Weichler

This file is part of Cylinder.

Cylinder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cylinder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cylinder.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "CylinderSettings.h"
#import "../Defines.h"
#import "twitter.h"
#import "CLEffect.h"

@interface PSListController()
-(id)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
@end

@interface CylinderSettingsListController()
{
    NSMutableDictionary *_settings;
    NSString *_defaultFooterText;
}
@property (nonatomic, retain, readwrite) NSMutableDictionary *settings;
@end

@implementation CylinderSettingsListController
@synthesize settings = _settings;

- (instancetype)init { 
    self = [super init];

    if (self) {
        self.settings = ([NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PATH] ?: DefaultPrefs);
        if(![[_settings valueForKey:PrefsEffectKey] isKindOfClass:NSArray.class]) [_settings setValue:nil forKey:PrefsEffectKey];
        _defaultFooterText = [[NSDictionary dictionaryWithContentsOfFile:@"/Library/PreferenceBundles/CylinderSettings.bundle/en.lproj/CylinderSettings.strings"] objectForKey:@"FOOTER_TEXT"];
    }
    return self;
}

- (NSArray *)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"CylinderSettings" target:self];
	}
	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];

    [settings setObject:value forKey:specifier.properties[@"key"]];
    [settings writeToFile:path atomically:YES];
    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];

    return ([settings objectForKey:specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)visitWebsite:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://r333d.com"] options:@{} completionHandler:nil];
}

-(void)visitBarrel:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.aaronash.barrel"] options:@{} completionHandler:nil];
}

- (void)visitTwitter:(id)sender {
    open_twitter();
}

- (void)visitWeibo:(id)sender {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"http://weibo.cn/r333d"] options:@{} completionHandler:nil];
}

- (void)visitGithub:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/rweichler/cylinder"] options:@{} completionHandler:nil];
}

- (void)visitReddit:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://reddit.com/r/cylinder"] options:@{} completionHandler:nil];
}

- (void)respring:(id)sender {
	// set the enabled value
	UITableViewCell *cell = [(UITableView*)self.table cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
	UISwitch *swit = (UISwitch *)cell.accessoryView;
	[_settings setObject: [NSNumber numberWithBool:swit.on] forKey:PrefsEnabledKey];

	[self writeSettings];
}

- (void)writeSettings {
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:self.settings format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];

	if (!data)
		return;
	[data writeToFile:PREFS_PATH atomically:NO];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef) kCylinderSettingsChanged, NULL, NULL, YES);
}

-(void)setSelectedEffects:(NSArray *)effects
{
    NSMutableString *text = [NSMutableString string];
    NSMutableArray *toWrite = [NSMutableArray arrayWithCapacity:effects.count];
    for(CLEffect *effect in effects)
    {
        if(!effect.name || !effect.directory) continue;

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:effect.name, PrefsEffectKey, effect.directory, PrefsEffectDirKey, nil];
        [toWrite addObject:dict];

        [text appendString:effect.name];
        if(effect != effects.lastObject)
        {
            [text appendString:@", "];
        }
    }

    UITableViewCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.detailTextLabel.text = text;

    [_settings setObject:toWrite forKey:PrefsEffectKey];
    self.selectedFormula = nil;
    [self writeSettings];
}

-(void)setFormulas:(NSDictionary *)formulas
{
    [_settings setObject:formulas forKey:PrefsFormulaKey];
}

-(void)setSelectedFormula:(NSString *)formula
{
    if(!formula)
    {
        [_settings removeObjectForKey:PrefsSelectedFormulaKey];
        return;
    }

    [_settings setObject:formula forKey:PrefsSelectedFormulaKey];

    NSDictionary *formulas = [_settings objectForKey:PrefsFormulaKey];
    NSArray *effects = [formulas objectForKey:formula];

    if(effects)
        [_settings setObject:effects forKey:PrefsEffectKey];

}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 1)
        return LOCALIZE(@"FOOTER_TEXT", _defaultFooterText);
    else
        return [super tableView:tableView titleForFooterInSection:section];
}

- (void)dealloc {
	// set the enabled value

	self.settings = nil;
}

@end
