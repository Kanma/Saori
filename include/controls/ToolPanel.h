#import <Cocoa/Cocoa.h>
#import <JUInspectorView/JUInspectorViewContainer.h>


@interface ToolPanel: JUInspectorViewContainer
{
    NSMutableArray* controllers;
}

- (void) addPanelFromNib:(NSString*)nib withName:(NSString*)name;

@end
