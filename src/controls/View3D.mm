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


/*************************************** METHODS ****************************************/

- (void) setup
{
    NSRect frame = [self frame];
    
    pWindow = Engine::getSingletonPtr()->createRenderWindow(
                                                    (size_t) self, "3D view",
                                                    (int) frame.size.width,
                                                    (int) frame.size.height,
                                                    false);
    
    // Retrieve the scene
    Scene* pScene = [Context context].scene;

    // Create the camera and the viewport
    pCameraController = pScene->create("CameraController");

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

    pCamera->setAspectRatio(float(window->getWidth()) / window->getHeight());

    pViewport = pCamera->createViewport(window);
    pViewport->setBackgroundColour(Ogre::ColourValue(0.1f, 0.1f, 0.1f));
    
    bManipulatingCamera = NO;
    bMovingCamera = NO;
    bRotatingCamera = NO;
    bZoomingCamera = NO;
    vertAngleTotal = 0.0f;
    
    [self setPostsFrameChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewSizeChanged:)
                                                 name:NSViewFrameDidChangeNotification
                                               object:self];

    [[Context context] pushStatusText:@"{{\\b S:} Camera functions}"];
}


- (void) dealloc
{
    // Destroy our entities
    [Context context].scene->destroy(pCameraController);

    // Destroy our viewport and render window
    pWindow->removeViewport(0);
    Ogre::Root::getSingletonPtr()->detachRenderTarget("3D view");

    [super dealloc];
}


- (void) viewSizeChanged:(NSNotification*)notification
{
    pWindow->windowMovedOrResized();

    pCamera->setAspectRatio(float(window->getWidth()) / window->getHeight());
}


- (void) translateBy:(const Athena::Math::Vector3&)offset
{
    assert(pCameraAxis);
    assert(pCameraController);
    
    pCameraAxis->translate(0.0f, 0.0f, offset.z);
    pCameraController->getTransforms()->translate(offset.x, offset.y, 0.0f);
}


- (void) rotateBy:(const Athena::Math::Quaternion&)quat
{
    assert(pCameraController);
    
    pCameraController->getTransforms()->rotate(quat);
}


- (void) rotateBy:(const Athena::Math::Degree&)angle around:(const Athena::Math::Vector3&)axis
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
    
    vertAngleTotal = 0.0f;
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


/**************************** IMPLEMENTATION OF NSResponder *****************************/

- (BOOL) acceptsFirstResponder
{
    return YES;
}


- (void) keyDown:(NSEvent*)theEvent
{
    if (!bManipulatingCamera)
    {
        NSString* key = [theEvent charactersIgnoringModifiers];
    
        if ([key compare:@"s"] == NSOrderedSame)
        {
            bManipulatingCamera = YES;
            bMovingCamera = NO;
            bRotatingCamera = NO;
            bZoomingCamera = NO;

            [[Context context] pushStatusText:@"{{\\b LMB:} Translate camera{\\tab}{\\b MMB:} Zoom{\\tab}{\\b RMB:} Orbit camera}"];

            NSCursor* cursor = [NSCursor openHandCursor];
            [cursor push];
        }
    }
}


- (void) keyUp:(NSEvent*)theEvent
{
    NSString* key = [theEvent charactersIgnoringModifiers];
    
    if ([key compare:@"s"] == NSOrderedSame)
    {
        if (bManipulatingCamera)
        {
            if (bMovingCamera || bRotatingCamera || bZoomingCamera)
                [NSCursor pop];

            bManipulatingCamera = NO;
            bMovingCamera = NO;
            bRotatingCamera = NO;
            bZoomingCamera = NO;

            [[Context context] popStatusText];

            [NSCursor pop];
        }
    }
}


- (void) mouseDown:(NSEvent*)theEvent
{
    if (bManipulatingCamera && !(bMovingCamera || bRotatingCamera || bZoomingCamera))
    {
        bMovingCamera = YES;
        previousMouseLocation = [NSEvent mouseLocation];
        
        [self changeCursor:@"TranslateCamera"];
    }
}


- (void) mouseUp:(NSEvent*)theEvent
{
    if (bManipulatingCamera)
    {
        bMovingCamera = NO;
        [NSCursor pop];
    }
}


- (void) mouseDragged:(NSEvent*)theEvent
{
    if (bManipulatingCamera && bMovingCamera)
    {
        int width = pWindow->getWidth();
        int height = pWindow->getHeight();

        NSPoint pos = [NSEvent mouseLocation];
        
        float x = ((float) (previousMouseLocation.x - pos.x) / width);
        float y = ((float) (previousMouseLocation.y - pos.y) / height);

		float FOVy = pCamera->getFOVy().valueRadians();
		float FOVx = FOVy * pCamera->getAspectRatio();

        float z = pCameraAxis->getPosition().z;

        float dx = x * 2.0f * z * (float) MathUtils::Tan(FOVx * 0.5f);
		float dy = y * 2.0f * z * (float) MathUtils::Tan(FOVy * 0.5f);

        [self translateBy:Vector3(dx, dy, 0.0f)];
        
        previousMouseLocation = pos;
    }
}


- (void) rightMouseDown:(NSEvent*)theEvent
{
    if (bManipulatingCamera && !(bMovingCamera || bRotatingCamera || bZoomingCamera))
    {
        bRotatingCamera = YES;
        previousMouseLocation = [NSEvent mouseLocation];
        
        [self changeCursor:@"RotateCamera"];
    }
}


- (void) rightMouseUp:(NSEvent*)theEvent
{
    if (bManipulatingCamera)
    {
        bRotatingCamera = NO;
        [NSCursor pop];
    }
}


- (void) rightMouseDragged:(NSEvent*)theEvent
{
    if (bManipulatingCamera && bRotatingCamera)
    {
        int width = pWindow->getWidth();
        int height = pWindow->getHeight();

        NSPoint pos = [NSEvent mouseLocation];
        
        float x = ((float) (previousMouseLocation.x - pos.x) / width);
        float y = ((float) (previousMouseLocation.y - pos.y) / height);

		// Compute the vertical rotation (stuck between -PI/2 and PI/2)
		float vertAngle = -2.0f * y;
		if (vertAngleTotal + vertAngle < -MathUtils::HALF_PI)
			vertAngle = -MathUtils::HALF_PI - vertAngleTotal;
		else if (vertAngleTotal + vertAngle > MathUtils::HALF_PI)
			vertAngle = MathUtils::HALF_PI - vertAngleTotal;
		vertAngleTotal += vertAngle;

		// Perform the rotations
        [self rotateBy:Degree(Radian(2.0f * x)) around:Vector3::UNIT_Y];
        [self rotateBy:Degree(Radian(vertAngle)) around:Vector3::UNIT_X];

        previousMouseLocation = pos;
    }
}


- (void) otherMouseDown:(NSEvent*)theEvent
{
    if (bManipulatingCamera && !(bMovingCamera || bRotatingCamera || bZoomingCamera))
    {
        bZoomingCamera = YES;
        previousMouseLocation = [NSEvent mouseLocation];
        
        [self changeCursor:@"ZoomCamera"];
    }
}


- (void) otherMouseUp:(NSEvent*)theEvent
{
    if (bManipulatingCamera)
    {
        bZoomingCamera = NO;
        [NSCursor pop];
    }
}


- (void) otherMouseDragged:(NSEvent*)theEvent
{
    if (bManipulatingCamera && bZoomingCamera)
    {
        int width = pWindow->getWidth();
        int height = pWindow->getHeight();

        NSPoint pos = [NSEvent mouseLocation];
        
        float x = ((float) (previousMouseLocation.x - pos.x) / width);
        float y = ((float) (previousMouseLocation.y - pos.y) / height);

		float FOVy = pCamera->getFOVy().valueRadians();
		float FOVx = FOVy * pCamera->getAspectRatio();

        float z = pCameraAxis->getPosition().z;

        float dx = x * 2.0f * z * (float) MathUtils::Tan(FOVx * 0.5f);
		float dy = y * 2.0f * z * (float) MathUtils::Tan(FOVy * 0.5f);

		float delta = dx + dy;

		if (z - delta < 0.0f)
			delta = z - 0.01f;

        [self translateBy:Vector3(0.0f, 0.0f, -delta)];
        
        previousMouseLocation = pos;
    }
}

@end
