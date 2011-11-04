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

    tCameraControl* cc = [Context context].cameraControl;

    cc->status         = CCS_NONE;
    cc->targetDist     = 10.0f;
    cc->vertAngleTotal = 0.0f;
    
    pCameraTransforms   = 0;
    pCamera             = 0;
    
    return self;
}


- (void) setupwithCamera:(Athena::Graphics::Visual::Camera*)camera
           andTransforms:(Athena::Entities::Transforms*)cameraTransforms
{
    pCamera = camera;
    pCameraTransforms = cameraTransforms;
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
    tCameraControl* cc = [Context context].cameraControl;
    
    if (cc->status == CCS_NONE)
    {
        NSString* key = [theEvent charactersIgnoringModifiers];
    
        if ([key compare:@"s"] == NSOrderedSame)
        {
            cc->status = CCS_GRABBED;

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
        tCameraControl* cc = [Context context].cameraControl;

        if (cc->status != CCS_NONE)
        {
            if (cc->status != CCS_GRABBED)
                [NSCursor pop];

            cc->status = CCS_NONE;

            [[Context context] popStatusText];

            [NSCursor pop];
        }
    }
}


- (void) mouseDown:(NSEvent*)theEvent
{
    tCameraControl* cc = [Context context].cameraControl;

    if (cc->status == CCS_GRABBED)
    {
        cc->status = CCS_MOVING;
        previousMouseLocation = [NSEvent mouseLocation];
        
        [self changeCursor:@"TranslateCamera"];
    }
}


- (void) mouseUp:(NSEvent*)theEvent
{
    tCameraControl* cc = [Context context].cameraControl;

    if (cc->status == CCS_MOVING)
    {
        cc->status = CCS_GRABBED;
        [NSCursor pop];
    }
}


- (void) mouseDragged:(NSEvent*)theEvent
{
    tCameraControl* cc = [Context context].cameraControl;

    if (cc->status == CCS_MOVING)
    {
        NSRect frame = [self frame];

        NSPoint pos = [NSEvent mouseLocation];
        
        float x = ((float) (previousMouseLocation.x - pos.x) / frame.size.width);
        float y = ((float) (previousMouseLocation.y - pos.y) / frame.size.height);

		float FOVy = pCamera->getFOVy().valueRadians();
		float FOVx = FOVy * pCamera->getAspectRatio();

        float z = cc->targetDist;

        float dx = x * 2.0f * z * (float) MathUtils::Tan(FOVx * 0.5f);
		float dy = y * 2.0f * z * (float) MathUtils::Tan(FOVy * 0.5f);

        [(View3D*) self.superview translateCameraBy:Vector3(dx, dy, 0.0f)];
        
        previousMouseLocation = pos;
    }
}


- (void) rightMouseDown:(NSEvent*)theEvent
{
    tCameraControl* cc = [Context context].cameraControl;

    if (cc->status == CCS_GRABBED)
    {
        cc->status = CCS_ROTATING;
        previousMouseLocation = [NSEvent mouseLocation];
        
        [self changeCursor:@"RotateCamera"];
    }
}


- (void) rightMouseUp:(NSEvent*)theEvent
{
    tCameraControl* cc = [Context context].cameraControl;

    if (cc->status == CCS_ROTATING)
    {
        cc->status = CCS_GRABBED;
        [NSCursor pop];
    }
}


- (void) rightMouseDragged:(NSEvent*)theEvent
{
    tCameraControl* cc = [Context context].cameraControl;

    if (cc->status == CCS_ROTATING)
    {
        NSRect frame = [self frame];

        NSPoint pos = [NSEvent mouseLocation];

        float x = ((float) (previousMouseLocation.x - pos.x));
        float y = ((float) (previousMouseLocation.y - pos.y));

		// Compute the vertical rotation (stuck between -PI/2 and PI/2)
		float vertAngle = -0.0035f * y;
		if (cc->vertAngleTotal + vertAngle < -MathUtils::HALF_PI)
			vertAngle = -MathUtils::HALF_PI - cc->vertAngleTotal;
		else if (cc->vertAngleTotal + vertAngle > MathUtils::HALF_PI)
			vertAngle = MathUtils::HALF_PI - cc->vertAngleTotal;
		cc->vertAngleTotal += vertAngle;

		// Perform the rotations
        [(View3D*) self.superview rotateCameraHorizontallyBy:Degree(Radian(0.0035f * x))
                                             andVerticallyBy:Degree(Radian(vertAngle))];

        previousMouseLocation = pos;
    }
}


- (void) otherMouseDown:(NSEvent*)theEvent
{
    tCameraControl* cc = [Context context].cameraControl;

    if (cc->status == CCS_GRABBED)
    {
        cc->status = CCS_ZOOMING;
        previousMouseLocation = [NSEvent mouseLocation];
        
        [self changeCursor:@"ZoomCamera"];
    }
}


- (void) otherMouseUp:(NSEvent*)theEvent
{
    tCameraControl* cc = [Context context].cameraControl;

    if (cc->status == CCS_ZOOMING)
    {
        cc->status = CCS_GRABBED;
        [NSCursor pop];
    }
}


- (void) otherMouseDragged:(NSEvent*)theEvent
{
    tCameraControl* cc = [Context context].cameraControl;

    if (cc->status == CCS_ZOOMING)
    {
        NSRect frame = [self frame];

        NSPoint pos = [NSEvent mouseLocation];
        
        float x = ((float) (previousMouseLocation.x - pos.x) / frame.size.width);
        float y = ((float) (previousMouseLocation.y - pos.y) / frame.size.height);

		float FOVy = pCamera->getFOVy().valueRadians();
		float FOVx = FOVy * pCamera->getAspectRatio();

        float z = cc->targetDist;

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
