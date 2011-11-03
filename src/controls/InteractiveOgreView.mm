#import <controls/InteractiveOgreView.h>
#import <controls/View3D.h>
#import <Ogre/OgreRoot.h>
#import <Ogre/OgreRenderWindow.h>


using namespace Athena;
using namespace Athena::Entities;
using namespace Athena::Graphics;
using namespace Athena::Graphics::Visual;
using namespace Athena::Math;


@implementation InteractiveOgreView

/*************************************** METHODS ****************************************/

- (id) initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];

    bManipulatingCamera = NO;
    bMovingCamera = NO;
    bRotatingCamera = NO;
    bZoomingCamera = NO;
    vertAngleTotal = 0.0f;
    
    pCameraAxis = 0;
    pCamera = 0;
    
    return self;
}


- (void) setupwithCamera:(Athena::Graphics::Visual::Camera*)camera andAxis:(Athena::Entities::Transforms*)cameraAxis
{
    pCamera = camera;
    pCameraAxis = cameraAxis;
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
        NSRect frame = [self frame];

        NSPoint pos = [NSEvent mouseLocation];
        
        float x = ((float) (previousMouseLocation.x - pos.x) / frame.size.width);
        float y = ((float) (previousMouseLocation.y - pos.y) / frame.size.height);

		float FOVy = pCamera->getFOVy().valueRadians();
		float FOVx = FOVy * pCamera->getAspectRatio();

        float z = pCameraAxis->getPosition().z;

        float dx = x * 2.0f * z * (float) MathUtils::Tan(FOVx * 0.5f);
		float dy = y * 2.0f * z * (float) MathUtils::Tan(FOVy * 0.5f);

        [(View3D*) self.superview translateCameraBy:Vector3(dx, dy, 0.0f)];
        
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
        NSRect frame = [self frame];

        NSPoint pos = [NSEvent mouseLocation];
        
        float x = ((float) (previousMouseLocation.x - pos.x) / frame.size.width);
        float y = ((float) (previousMouseLocation.y - pos.y) / frame.size.height);

		// Compute the vertical rotation (stuck between -PI/2 and PI/2)
		float vertAngle = -2.0f * y;
		if (vertAngleTotal + vertAngle < -MathUtils::HALF_PI)
			vertAngle = -MathUtils::HALF_PI - vertAngleTotal;
		else if (vertAngleTotal + vertAngle > MathUtils::HALF_PI)
			vertAngle = MathUtils::HALF_PI - vertAngleTotal;
		vertAngleTotal += vertAngle;

		// Perform the rotations
        [(View3D*) self.superview rotateCameraBy:Degree(Radian(2.0f * x)) around:Vector3::UNIT_Y];
        [(View3D*) self.superview rotateCameraBy:Degree(Radian(vertAngle)) around:Vector3::UNIT_X];

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
        NSRect frame = [self frame];

        NSPoint pos = [NSEvent mouseLocation];
        
        float x = ((float) (previousMouseLocation.x - pos.x) / frame.size.width);
        float y = ((float) (previousMouseLocation.y - pos.y) / frame.size.height);

		float FOVy = pCamera->getFOVy().valueRadians();
		float FOVx = FOVy * pCamera->getAspectRatio();

        float z = pCameraAxis->getPosition().z;

        float dx = x * 2.0f * z * (float) MathUtils::Tan(FOVx * 0.5f);
		float dy = y * 2.0f * z * (float) MathUtils::Tan(FOVy * 0.5f);

		float delta = dx + dy;

		if (z - delta < 0.0f)
			delta = z - 0.01f;

        [(View3D*) self.superview translateCameraBy:Vector3(0.0f, 0.0f, -delta)];
        
        previousMouseLocation = pos;
    }
}

@end
