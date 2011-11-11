#import <controls/ToolPanel.h>
#import <controls/Panel.h>
#import <JUInspectorView/JUInspectorView.h>


@implementation ToolPanel

/*************************************** METHODS ****************************************/

- (void) addPanelFromNib:(NSString*)nib withName:(NSString*)name
{
    NSViewController* controller = [[NSViewController alloc] initWithNibName:nib bundle:nil];

    JUInspectorView* view = (JUInspectorView*) [controller view];
    view.name = name;

    [self addInspectorView:view expanded:YES];

    [controllers addObject:controller];
    
    [(Panel*) view.body setup];
}

@end
