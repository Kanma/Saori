#import <Cocoa/Cocoa.h>
#import <Ogre/OSX/OgreOSXCocoaView.h>
#import <Context.h>
#import <Athena-Entities/Entity.h>
#import <Athena-Entities/Transforms.h>
#import <Athena-Graphics/Visual/Camera.h>


@interface InteractiveOgreView: OgreView
{
    // Camera manipulation
    BOOL    bManipulatingCamera;
    BOOL    bMovingCamera;
    BOOL    bRotatingCamera;
    BOOL    bZoomingCamera;
    NSPoint previousMouseLocation;
    float   vertAngleTotal;

    Athena::Entities::Transforms*       pCameraAxis;
    Athena::Graphics::Visual::Camera*   pCamera;
}

- (void) setupwithCamera:(Athena::Graphics::Visual::Camera*)camera andAxis:(Athena::Entities::Transforms*)cameraAxis;

@end
