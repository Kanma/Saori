#import <Cocoa/Cocoa.h>
#import <Athena-Entities/Scene.h>


@interface Context : NSObject
{
@private
    // UI
    NSTextView* statusBar;
    
    // Others
	Athena::Entities::Scene* scene;

    NSMutableArray* statusTexts;
}

// Properties
@property (readwrite, assign, nonatomic) NSTextView*              statusBar;
@property (readonly, assign, nonatomic)  Athena::Entities::Scene* scene;

// Methods
+ (Context*) context;

- (Athena::Entities::Scene*) createScene:(NSString*)name;
- (void) destroyScene;

- (void) pushStatusText:(NSString*)text;
- (void) popStatusText;

@end
