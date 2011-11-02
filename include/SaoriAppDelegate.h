#import <Cocoa/Cocoa.h>
#import <Athena/Engine.h>
#import <MeshViewerState.h>
#import <controls/View3D.h>


@interface SaoriAppDelegate : NSObject <NSApplicationDelegate>
{
@private
    // UI
    NSWindow*           window;
    OgreView*           mainOgreView;
    View3D*             view3D;
    NSSegmentedControl* btnPolygonMode;
    NSTextView*         statusBar;

    // Attributes
    Athena::Engine   engine;
    MeshViewerState* pMeshViewerState;
}

// Outlets
@property (assign) IBOutlet NSWindow*           window;
@property (assign) IBOutlet OgreView*           mainOgreView;
@property (assign) IBOutlet View3D*             view3D;
@property (assign) IBOutlet NSSegmentedControl* btnPolygonMode;
@property (assign) NSTextView*                  statusBar;

// Actions
- (IBAction) openFile:(id)sender;
- (IBAction) changePolygonMode:(id)sender;
- (IBAction) toggleCameraLight:(id)sender;
- (IBAction) changeCameraLightColor:(id)sender;

@end
