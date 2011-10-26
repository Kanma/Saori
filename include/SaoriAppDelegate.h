#import <Cocoa/Cocoa.h>
#import <Athena/Engine.h>
#import <Ogre/OSX/OgreOSXCocoaView.h>
#import "MeshViewerState.h"


@interface SaoriAppDelegate : NSObject <NSApplicationDelegate>
{
@private
    // UI
    NSWindow* window;
	OgreView* ogreView;

    // Attributes
    Athena::Engine   engine;
    MeshViewerState* pMeshViewerState;
}

// Outlets
@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet OgreView* ogreView;

// Actions
- (IBAction) openFile:(id)sender;

@end
