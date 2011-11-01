#import <Cocoa/Cocoa.h>
#import <Ogre/OSX/OgreOSXCocoaView.h>
#import <Context.h>
#import <Athena-Entities/Entity.h>
#import <Athena-Entities/Transforms.h>
#import <Athena-Graphics/Visual/Camera.h>
#import <Athena-Graphics/Visual/PointLight.h>


@interface View3D: OgreView
{
@private
    Athena::Entities::Entity*               pCameraController;
    Athena::Entities::Transforms*           pCameraAxis;
    Athena::Graphics::Visual::Camera*       pCamera;
    Athena::Graphics::Visual::PointLight*   pCameraLight;
    Ogre::RenderWindow*                     pWindow;
    Ogre::Viewport*                         pViewport;

    // Camera manipulation
    BOOL                                    bManipulatingCamera;
    BOOL                                    bMovingCamera;
    BOOL                                    bRotatingCamera;
    BOOL                                    bZoomingCamera;
    NSPoint                                 previousMouseLocation;
    float                                   vertAngleTotal;
}

// Properties
@property (readwrite, assign, nonatomic) Athena::Math::Real  aspectRatio;
@property (readwrite, assign, nonatomic) BOOL                lightEnabled;
@property (readwrite, assign, nonatomic) Athena::Math::Color lightColor;
@property (readwrite, assign, nonatomic) Ogre::PolygonMode   polygonMode;

// Methods
- (void) setup;
- (void) translateBy:(const Athena::Math::Vector3&)offset;
- (void) rotateBy:(const Athena::Math::Quaternion&)quat;
- (void) rotateBy:(const Athena::Math::Degree&)angle around:(const Athena::Math::Vector3&)axis;
- (void) frameAll;

@end
