#import <Cocoa/Cocoa.h>
#import <Ogre/OSX/OgreOSXCocoaView.h>
#import <Context.h>
#import <Athena-Entities/Entity.h>
#import <Athena-Entities/Transforms.h>
#import <Athena-Graphics/Visual/Camera.h>


@interface InteractiveOgreView: OgreView
{
    Athena::Entities::Transforms*     pCameraTransforms;
    Athena::Graphics::Visual::Camera* pCamera;
    NSPoint                           previousMouseLocation;
    
    NSCursor*                         cursorTranslateCamera;
    NSCursor*                         cursorRotateCamera;
    NSCursor*                         cursorZoomCamera;
}

- (void) setupwithCamera:(Athena::Graphics::Visual::Camera*)camera
           andTransforms:(Athena::Entities::Transforms*)cameraTransforms;

@end
