#import <Cocoa/Cocoa.h>

@interface SaoriAppDelegate : NSObject <NSApplicationDelegate>
{
@private
    NSWindow* window;
}

@property (assign) IBOutlet NSWindow* window;

@end
