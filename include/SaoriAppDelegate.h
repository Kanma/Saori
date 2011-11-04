#import <Cocoa/Cocoa.h>
#import <Athena/Engine.h>
#import <MeshViewerState.h>


@interface SaoriAppDelegate : NSObject <NSApplicationDelegate>
{
@private
    // UI
    NSWindow*        window;
    OgreView*        mainOgreView;
    NSView*          workingZone;
    NSTextView*      statusBar;

    // Attributes
    Athena::Engine   engine;
    MeshViewerState* pMeshViewerState;
}

// Outlets
@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet OgreView* mainOgreView;
@property (assign) IBOutlet NSView*   workingZone;
@property (assign) NSTextView*        statusBar;

// Actions
- (IBAction) openFile:(id)sender;

@end
