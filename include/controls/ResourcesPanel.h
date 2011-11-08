#import <Cocoa/Cocoa.h>

@interface ResourcesPanel: NSView <NSBrowserDelegate>
{
@private
    IBOutlet NSBrowser* browser;
}

@end
