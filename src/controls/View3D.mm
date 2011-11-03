#import <controls/View3D.h>
#import <Athena/Engine.h>
#import <Athena-Graphics/Visual/Object.h>
#import <Athena-Math/Vector3.h>
#import <Athena-Math/MathUtils.h>
#import <Ogre/OgreRoot.h>
#import <Ogre/OgreRenderWindow.h>


using namespace Athena;
using namespace Athena::Entities;
using namespace Athena::Graphics;
using namespace Athena::Graphics::Visual;
using namespace Athena::Math;


@implementation View3D

/************************************** PROPERTIES **************************************/

@synthesize ogreView;


- (void) setAspectRatio:(Real)value
{
    assert(pCamera);
    
    pCamera->setAspectRatio(value);
}


- (Real) aspectRatio
{
    assert(pCamera);
    
    return pCamera->getAspectRatio();
}


- (void) setPolygonMode:(Ogre::PolygonMode)mode
{
    assert(pCamera);
    
    pCamera->setPolygonMode(mode);
}


- (Ogre::PolygonMode) polygonMode
{
    assert(pCamera);
    
    return pCamera->getPolygonMode();
}


- (void) setLightEnabled:(BOOL)enabled
{
    assert(pCameraLight);
    
    pCameraLight->getOgreLight()->setVisible(enabled == YES);
}


- (BOOL) lightEnabled
{
    assert(pCameraLight);
    
    return (pCameraLight->getOgreLight()->getVisible() == YES);
}


- (void) setLightColor:(Athena::Math::Color)color
{
    assert(pCameraLight);
    
    pCameraLight->setDiffuseColor(color);
}


- (Athena::Math::Color) lightColor
{
    assert(pCameraLight);
    
    return pCameraLight->getDiffuseColor();
}


- (void) setBackgroundColor:(Athena::Math::Color)color
{
    assert(pViewport);

    pViewport->setBackgroundColour(toOgre(color));
}


- (Athena::Math::Color) backgroundColor
{
    assert(pViewport);

    return fromOgre(pViewport->getBackgroundColour());
}


/*************************************** ACTIONS ****************************************/

- (IBAction) changePolygonMode:(id)sender
{
    switch ([sender selectedSegment])
    {
        case 0: self.polygonMode = Ogre::PM_SOLID; break;
        case 1: self.polygonMode = Ogre::PM_WIREFRAME; break;
        case 2: self.polygonMode = Ogre::PM_POINTS; break;
    }
}


- (IBAction) toggleCameraLight:(id)sender
{
    self.lightEnabled = ([sender state] == NSOnState);
}


- (IBAction) changeCameraLightColor:(id)sender
{
    Math::Color color;

    NSColor* rgbColor = [[sender color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    [rgbColor getRed:&color.r green:&color.g blue:&color.b alpha:&color.a];

    self.lightColor = color;
}


/*************************************** METHODS ****************************************/

- (void) setup:(NSString*)viewName
{
    NSRect frame = [ogreView frame];
    
    pWindow = Engine::getSingletonPtr()->createRenderWindow(
                                                (size_t) ogreView,
                                                [[viewName stringByAppendingString:@"/RenderWindow"] UTF8String],
                                                (int) frame.size.width,
                                                (int) frame.size.height,
                                                false);
    
    // Retrieve the scene
    Scene* pScene = [Context context].scene;

    // Create the camera and the viewport
    pCameraController = pScene->create([[viewName stringByAppendingString:@"/CameraController"] UTF8String]);

    pCameraAxis = new Transforms("CameraTransforms", pCameraController->getComponentsList());
    pCameraAxis->translate(0.0f, 0.0f, 10.0f);

    pCamera = new Camera("Camera", pCameraController->getComponentsList());
    pCamera->setTransforms(pCameraAxis);
    pCamera->setNearClipDistance(0.1f);
    pCamera->setFarClipDistance(1000.0f);
    pCamera->setFOVy(Degree(45.0f));

    pCameraLight = new PointLight("Light", pCameraController->getComponentsList());
    pCameraLight->setTransforms(pCameraAxis);
    pCameraLight->setDiffuseColor(Color(0.7f, 0.7f, 0.7f));

    pCamera->setAspectRatio(frame.size.width / frame.size.height);

    pViewport = pCamera->createViewport(pWindow);
    pViewport->setBackgroundColour(Ogre::ColourValue(0.1f, 0.1f, 0.1f));
        
    [self setPostsFrameChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewSizeChanged:)
                                                 name:NSViewFrameDidChangeNotification
                                               object:self];

    [[Context context] pushStatusText:@"{{\\b S:} Camera functions}"];

    [ogreView setupwithCamera:pCamera andAxis:pCameraAxis];
}


- (void) dealloc
{
    // Destroy our entities
    [Context context].scene->destroy(pCameraController);

    // Destroy our viewport and render window
    pWindow->removeViewport(0);
    Ogre::Root::getSingletonPtr()->detachRenderTarget(pWindow->getName());

    [super dealloc];
}


- (void) viewSizeChanged:(NSNotification*)notification
{
    pWindow->windowMovedOrResized();

    pCamera->setAspectRatio(float(pWindow->getWidth()) / pWindow->getHeight());
}


- (void) translateCameraBy:(const Athena::Math::Vector3&)offset
{
    assert(pCameraAxis);
    assert(pCameraController);
    
    pCameraAxis->translate(0.0f, 0.0f, offset.z);
    pCameraController->getTransforms()->translate(offset.x, offset.y, 0.0f);
}


- (void) rotateCameraBy:(const Athena::Math::Quaternion&)quat
{
    assert(pCameraController);
    
    pCameraController->getTransforms()->rotate(quat);
}


- (void) rotateCameraBy:(const Athena::Math::Degree&)angle around:(const Athena::Math::Vector3&)axis
{
    assert(pCameraAxis);
    assert(pCameraController);
    
    pCameraController->getTransforms()->rotate(axis, angle);
}


- (void) frameAll
{
    // Assertions
    assert(pScene);
    
    // Declarations
    AxisAlignedBox boundingBox;
    float boundingRadius = 0.0f;
    Scene* pScene = [Context context].scene;

    // Compute the bounding box and radius of the whole scene
    Scene::tEntitiesIterator iter = pScene->getEntitiesIterator();
    while (iter.hasMoreElements())
    {
        Entity* pEntity = iter.getNext();
        ComponentsList::tComponentsIterator iter2 = pEntity->getComponentsIterator();
        while (iter2.hasMoreElements())
        {
            Entities::Component* pComponent = iter2.getNext();
            if (pComponent->getType() == Object::TYPE)
            {
                Ogre::Entity* pOgreEntity = Object::cast(pComponent)->getOgreEntity();
                boundingBox.merge(fromOgre(pOgreEntity->getWorldBoundingBox(true)));
                boundingRadius = std::max(boundingRadius, pOgreEntity->getBoundingRadius());
            }
        }
    }
    
    Radian angle;
    if (pCamera->getAspectRatio() >= 1.0f)
        angle = pCamera->getFOVy() * 0.5f;
    else
        angle = pCamera->getFOVy() * pCamera->getAspectRatio() * 0.5f;

    pCameraController->getTransforms()->setPosition(boundingBox.getCenter());
    pCameraAxis->setPosition(0.0f, 0.0f, std::max(boundingRadius / MathUtils::Tan(angle),
                                                  boundingRadius + pCamera->getNearClipDistance()));
    pCameraAxis->setDirection(Vector3::NEGATIVE_UNIT_Z);
    
    // vertAngleTotal = 0.0f;
}


- (void) changeCursor:(NSString*)name
{
    NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/Contents/Resources/Cursors/%@.png",name];
    NSImage* image = [[NSImage alloc] initWithContentsOfFile:path];

    NSPoint hotSpot;
    hotSpot.x = image.size.width / 2;
    hotSpot.y = image.size.height / 2;

    NSCursor* cursor = [[NSCursor alloc] initWithImage:image hotSpot:hotSpot];

    [cursor push];
}

@end
