#import <SaoriAppDelegate.h>
#import <Athena/GameStates/GameStateManager.h>
#import <Athena/Tasks/TaskManager.h>
#import <Ogre/OgreWindowEventUtilities.h>

using namespace Athena;
using namespace Athena::GameStates;

using Ogre::WindowEventUtilities;


@implementation SaoriAppDelegate

@synthesize window;
@synthesize ogreView;


- (void) applicationDidFinishLaunching:(NSNotification*)aNotification
{
    // Initialize Athena, using the custom view
    engine.setup("athena.cfg");
    
    NSRect frame = [ogreView frame];
    engine.createRenderWindow((size_t) ogreView, "3D view", frame.size.width,
                              frame.size.height, false);

    // Create our gamestate
    GameStateManager* pGameStateManager = engine.getGameStateManager();

    pMeshViewerState = new MeshViewerState();

    pGameStateManager->registerState(1, pMeshViewerState);
    pGameStateManager->pushState(1);

	// Create a timer to render at 50fps
	[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(stepOneFrame) userInfo:NULL repeats:YES];
}


- (void) stepOneFrame
{
	try
	{
	    WindowEventUtilities::messagePump();
		engine.getTaskManager()->step(20000);
        // NSLog(@"stepOneFrame");
	}
	catch (Ogre::Exception& e)
	{
		std::cerr << "An exception has occured: " << e.getFullDescription().c_str() << std::endl;
	}
}

@end
