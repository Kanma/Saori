#import <Cocoa/Cocoa.h>
#import <Athena/Engine.h>
#import <MeshViewerState.h>


@interface SaoriAppDelegate : NSObject <NSApplicationDelegate>
{
@private
    // UI
    IBOutlet NSWindow*                   window;
    IBOutlet OgreView*                   mainOgreView;
    IBOutlet NSView*                     workingZone;
    IBOutlet NSScrollView*               toolPanelScroller;
    IBOutlet JUInspectorViewContainer*   toolPanel;
    NSTextView*                          statusBar;

    // Attributes
    Athena::Engine   engine;
    MeshViewerState* pMeshViewerState;
}

// Actions
- (IBAction) openFile:(id)sender;

@end
