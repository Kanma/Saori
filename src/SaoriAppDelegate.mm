#import <SaoriAppDelegate.h>
#import <Athena/GameStates/GameStateManager.h>
#import <Athena/Tasks/TaskManager.h>
#import <Ogre/OgreWindowEventUtilities.h>

using namespace Athena;
using namespace Athena::GameStates;

using Ogre::WindowEventUtilities;


@implementation SaoriAppDelegate

@synthesize window;
@synthesize mainOgreView;
@synthesize view3D;
@synthesize statusBar;


- (void) applicationDidFinishLaunching:(NSNotification*)aNotification
{
    // Create the text view of the status bar
    NSRect statusBarFrame = [window frame];
    statusBarFrame.origin.x = 0;
    statusBarFrame.origin.y = 0;
    statusBarFrame.size.height = 18;
    statusBar = [[NSTextView alloc] initWithFrame:statusBarFrame];
    [statusBar setDrawsBackground:NO];
    [statusBar setEditable:NO];
    [statusBar setRichText:YES];
    [statusBar setSelectable:NO];
    [window.contentView addSubview:statusBar];

    [Context context].statusBar = statusBar;

    // Initialize Athena
    engine.setup("athena.cfg");

    // Create the main Ogre view (hidden, to initialize OpenGL)
    NSRect frame = [mainOgreView frame];
    Engine::getSingletonPtr()->createRenderWindow((size_t) mainOgreView, "MainOgreView",
                                                  (int) frame.size.width,
                                                  (int) frame.size.height,
                                                  false);

    // Create the scene
    [[Context context] createScene:@"MainScene"];

    // Setup our views
    [view3D setup];

    // Create our gamestate
    GameStateManager* pGameStateManager = engine.getGameStateManager();

    pMeshViewerState = new MeshViewerState();

    pGameStateManager->registerState(1, pMeshViewerState);
    pGameStateManager->pushState(1);

    [window makeFirstResponder:view3D];

	// Create a timer to render at 50fps
	[NSTimer scheduledTimerWithTimeInterval:0.02 target:self
	                               selector:@selector(stepOneFrame)
	                               userInfo:NULL repeats:YES];
}


- (void) stepOneFrame
{
	try
	{
	    WindowEventUtilities::messagePump();
		engine.getTaskManager()->step(20000);
	}
	catch (Ogre::Exception& e)
	{
		std::cerr << "An exception has occured: " << e.getFullDescription().c_str() << std::endl;
	}
}


- (IBAction) openFile:(id)sender
{
    NSOpenPanel* op = [NSOpenPanel openPanel];
    if ([op runModal] == NSOKButton)
    {
        NSString* filename = [op filename];
        if (pMeshViewerState->loadMesh([filename UTF8String]))
            [view3D frameAll];
    }
}

@end
