#import <Cocoa/Cocoa.h>

@interface ResourcesPanel: NSView <NSBrowserDelegate>
{
@private
    IBOutlet NSBrowser* browser;
    IBOutlet NSButton*  btnAdd;
    IBOutlet NSButton*  btnRemove;

    NSMutableArray*     locations;
}

@end
