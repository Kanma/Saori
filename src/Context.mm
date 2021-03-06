#import <Context.h>
#import <Athena-Graphics/Visual/World.h>
#import <Athena-Math/Color.h>
#import <Ogre/OgreResourceGroupManager.h>
#import <Ogre/OgreSceneManager.h>

using namespace Athena::Entities;
using namespace Athena::Graphics;
using namespace Athena::Math;


Context* gContext = [[Context alloc] init];


@interface Context (hidden)

- (void) updateStatusText;

@end


@implementation Context

/************************************** PROPERTIES **************************************/

@synthesize statusBar;
@synthesize scene;


- (tCameraControl*) cameraControl
{
    return &cameraControl;
}


/*************************************** METHODS ****************************************/

- (id) init
{
    [super init];
    
    statusBar = nil;
    scene = 0;

    statusTexts = [[NSMutableArray alloc] initWithCapacity:10];
    
    return self;
}


+ (Context*) context
{
    return gContext;
}


- (Scene*) createScene:(NSString*)name
{
    [self destroyScene];
    
    // Create the scene
    scene = new Scene([name UTF8String]);

    Visual::World* pVisualWorld = new Visual::World("", scene->getComponentsList());

    Ogre::SceneManager* pSceneManager = pVisualWorld->createSceneManager(Ogre::ST_GENERIC);
    pSceneManager->setShadowTechnique(Ogre::SHADOWTYPE_STENCIL_ADDITIVE);
    pSceneManager->setShadowFarDistance(20.0f);

    pVisualWorld->setAmbientLight(Color(0.5f, 0.5f, 0.5f));

    scene->show();
    
    return scene;
}


- (void) destroyScene
{
    if (scene)
        delete scene;
    
    scene = 0;
}


- (void) pushStatusText:(NSString*)text
{
    [statusTexts addObject:text];
    [self updateStatusText];
}


- (void) popStatusText
{
    [statusTexts removeLastObject];
    [self updateStatusText];
}


- (void) updateStatusText
{
    if ([statusTexts count] > 0)
    {
        NSString* text = [statusTexts lastObject];
        NSAttributedString* rtf = [[NSAttributedString alloc] initWithRTF:[text dataUsingEncoding: [NSString defaultCStringEncoding]]
                                                       documentAttributes:nil];
        [[statusBar textStorage] setAttributedString:rtf];
        [rtf release];
    }
    else
    {
        [statusBar setString:@""];
    }
}

@end
