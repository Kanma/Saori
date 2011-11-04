#import <Cocoa/Cocoa.h>
#import <Athena-Entities/Scene.h>


typedef enum _tCameraControlStatus
{
    CCS_NONE,
    CCS_GRABBED,
    CCS_MOVING,
    CCS_ROTATING,
    CCS_ZOOMING,
} tCameraControlStatus;


struct tCameraControl
{
    tCameraControlStatus status;
    float                targetDist;
    float                vertAngleTotal;
};


@interface Context : NSObject
{
@private
    // UI
    NSTextView* statusBar;
    
    // Others
	Athena::Entities::Scene* scene;
    tCameraControl           cameraControl;

    NSMutableArray* statusTexts;
}

// Properties
@property (readwrite, assign, nonatomic) NSTextView*              statusBar;
@property (readonly, assign, nonatomic)  Athena::Entities::Scene* scene;
@property (readonly, assign, nonatomic)  tCameraControl*          cameraControl;

// Methods
+ (Context*) context;

- (Athena::Entities::Scene*) createScene:(NSString*)name;
- (void) destroyScene;

- (void) pushStatusText:(NSString*)text;
- (void) popStatusText;

@end
