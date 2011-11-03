#import <Cocoa/Cocoa.h>
#import <Context.h>
#import <Athena-Entities/Entity.h>
#import <Athena-Entities/Transforms.h>
#import <Athena-Graphics/Visual/Camera.h>
#import <Athena-Graphics/Visual/PointLight.h>
#import <controls/InteractiveOgreView.h>


@interface View3D: NSView
{
@private
    // UI
    InteractiveOgreView*                    ogreView;

    // 3D objects
    Athena::Entities::Entity*               pCameraController;
    Athena::Entities::Transforms*           pCameraAxis;
    Athena::Graphics::Visual::Camera*       pCamera;
    Athena::Graphics::Visual::PointLight*   pCameraLight;
    Ogre::RenderWindow*                     pWindow;
    Ogre::Viewport*                         pViewport;
}


// Outlets
@property (assign) IBOutlet InteractiveOgreView* ogreView;

// Actions
- (IBAction) changePolygonMode:(id)sender;
- (IBAction) toggleCameraLight:(id)sender;
- (IBAction) changeCameraLightColor:(id)sender;


// Properties
@property (readwrite, assign, nonatomic) Athena::Math::Real  aspectRatio;
@property (readwrite, assign, nonatomic) BOOL                lightEnabled;
@property (readwrite, assign, nonatomic) Athena::Math::Color lightColor;
@property (readwrite, assign, nonatomic) Ogre::PolygonMode   polygonMode;
@property (readwrite, assign, nonatomic) Athena::Math::Color backgroundColor;

// Methods
- (void) setup:(NSString*)viewName;
- (void) translateCameraBy:(const Athena::Math::Vector3&)offset;
- (void) rotateCameraBy:(const Athena::Math::Quaternion&)quat;
- (void) rotateCameraBy:(const Athena::Math::Degree&)angle around:(const Athena::Math::Vector3&)axis;
- (void) frameAll;

@end
