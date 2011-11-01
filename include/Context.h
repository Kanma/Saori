#import <Cocoa/Cocoa.h>
#import <Athena-Entities/Scene.h>


@interface Context : NSObject
{
@private
	Athena::Entities::Scene* scene;
}

// Properties
@property (readonly, assign, nonatomic)  Athena::Entities::Scene* scene;

// Methods
+ (Context*) context;
- (Athena::Entities::Scene*) createScene:(NSString*)name;
- (Athena::Entities::Scene*) destroyScene;

@end
