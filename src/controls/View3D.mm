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
    // Create the render window
    NSRect frame = [ogreView frame];
    pWindow = Engine::getSingletonPtr()->createRenderWindow(
                                                (size_t) ogreView,
                                                [[viewName stringByAppendingString:@"/RenderWindow"] UTF8String],
                                                (int) frame.size.width,
                                                (int) frame.size.height,
                                                false);
    
    // Retrieve the scene
    Scene* pScene = [Context context].scene;

    // Create the camera controller
    pCameraController = pScene->create([[viewName stringByAppendingString:@"/CameraController"] UTF8String]);
    pCameraController->getTransforms()->translate(0.0f, 0.0f, [Context context].cameraControl->targetDist);

    pCamera = new Camera("Camera", pCameraController->getComponentsList());
    pCamera->setNearClipDistance(0.1f);
    pCamera->setFarClipDistance(1000.0f);
    pCamera->setFOVy(Degree(45.0f));

    pCameraLight = new PointLight("Light", pCameraController->getComponentsList());
    pCameraLight->setDiffuseColor(Color(0.7f, 0.7f, 0.7f));

    pCamera->setAspectRatio(frame.size.width / frame.size.height);

    // Create the viewport
    pViewport = pCamera->createViewport(pWindow);
    pViewport->setBackgroundColour(Ogre::ColourValue(0.1f, 0.1f, 0.1f));

    // Notifications
    [self setPostsFrameChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewSizeChanged:)
                                                 name:NSViewFrameDidChangeNotification
                                               object:self];

    [[Context context] pushStatusText:@"{{\\b S:} Camera functions}"];

    [ogreView setupwithCamera:pCamera andTransforms:pCamera->getTransforms()];
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

    tCameraControl* cc = [Context context].cameraControl;

    if (cc->targetDist + offset.z < 0.01f)
    {
        pCameraController->getTransforms()->translate(offset.x, offset.y, -cc->targetDist + 0.01f);
        cc->targetDist = 0.01f;
    }
    else
    {
        cc->targetDist += offset.z;
        pCameraController->getTransforms()->translate(offset.x, offset.y, offset.z);
    }
}


- (void) rotateCameraHorizontallyBy:(const Athena::Math::Degree&)angleHor
                    andVerticallyBy:(const Athena::Math::Degree&)angleVert
{
    assert(pCameraController);

    Quaternion cameraOrientation = pCameraController->getTransforms()->getOrientation();

    Vector3 diff = cameraOrientation * Vector3(0.0f, 0.0f, [Context context].cameraControl->targetDist);
    Vector3 finalPos = pCameraController->getTransforms()->getPosition();

    // Perform the up/down rotation
    Quaternion rotVert(angleVert, cameraOrientation * Vector3::UNIT_X);
    pCameraController->getTransforms()->rotate(rotVert, Transforms::TS_WORLD);

    Vector3 rotated_diff = rotVert * diff;
    finalPos -= diff;
    finalPos += rotated_diff;

    // Perform the orbital rotation
    Quaternion rotHor(angleHor, Vector3::UNIT_Y);
    pCameraController->getTransforms()->rotate(rotHor, Transforms::TS_WORLD);

    rotated_diff = rotHor * diff;
    finalPos -= diff;
    finalPos += rotated_diff;

    pCameraController->getTransforms()->setPosition(finalPos);
}


- (void) frameAll
{
    // Assertions
    assert(pScene);
    
    // Declarations
    AxisAlignedBox boundingBox;
    float boundingRadius = 0.0f;
    Scene* pScene = [Context context].scene;
    tCameraControl* cc = [Context context].cameraControl;

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

    cc->targetDist = std::max(boundingRadius / MathUtils::Tan(angle),
                              boundingRadius + pCamera->getNearClipDistance());

    pCameraController->getTransforms()->setPosition(boundingBox.getCenter());
    pCameraController->getTransforms()->setDirection(Vector3::NEGATIVE_UNIT_Z);
    pCameraController->getTransforms()->translate(0.0f, 0.0f, cc->targetDist);
    
    cc->vertAngleTotal = 0.0f;
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
