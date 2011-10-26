#include <MeshViewerState.h>
#include <Athena/Engine.h>
#include <Athena/Tasks/TaskManager.h>
#include <Athena/GameStates/GameStateManager.h>
#include <Athena-Entities/Scene.h>
#include <Athena-Entities/Entity.h>
#include <Athena-Entities/Transforms.h>
#include <Athena-Graphics/Visual/Camera.h>
#include <Athena-Graphics/Visual/World.h>
#include <Athena-Math/Vector3.h>
#include <Ogre/OgreRoot.h>
#include <Ogre/OgreRenderTexture.h>
#include <Ogre/OgreRenderWindow.h>
#include <Ogre/OgreSceneManager.h>


using namespace Athena;
using namespace Athena::Entities;
using namespace Athena::Graphics;
using namespace Athena::Graphics::Visual;
using namespace Athena::Math;


static const char* __CONTEXT__ = "Mesh Viewer State";


/***************************** CONSTRUCTION / DESTRUCTION ******************************/

MeshViewerState::MeshViewerState()
: m_pScene(0), m_pEntity(0), m_pCameraController(0), m_pViewport(0)
{
}


MeshViewerState::~MeshViewerState()
{
}


/************************************** METHODS ****************************************/



/************************ METHODS TO BE OVERRIDEN BY EACH STATE ************************/

void MeshViewerState::enter()
{
	// Create the scene
	m_pScene = new Scene("MeshViewer");

    Visual::World* pVisualWorld = new Visual::World("", m_pScene->getComponentsList());

    Ogre::SceneManager* pSceneManager = pVisualWorld->createSceneManager(Ogre::ST_GENERIC);
    pSceneManager->setShadowTechnique(Ogre::SHADOWTYPE_STENCIL_ADDITIVE);
    pSceneManager->setShadowFarDistance(20.0f);

    pVisualWorld->setAmbientLight(Color(0.4f, 0.4f, 0.4f));

    m_pScene->show();

    // Create the camera and the viewport
	m_pCameraController = m_pScene->create("CameraController");

    Camera* pCamera = new Camera("Camera", m_pCameraController->getComponentsList());
	pCamera->setNearClipDistance(0.1f);
	pCamera->setFarClipDistance(100.0f);
    pCamera->setFOVy(Degree(45.0f));

    Ogre::RenderWindow* pWindow = Engine::getSingletonPtr()->getMainWindow();

    pCamera->setAspectRatio(float(pWindow->getWidth()) / pWindow->getHeight());

    m_pViewport = pCamera->createViewport(pWindow);
    m_pViewport->setBackgroundColour(Ogre::ColourValue(0.4f, 0.4f, 0.4f));
}


void MeshViewerState::exit()
{
	Engine::getSingletonPtr()->getMainWindow()->removeViewport(0);

	delete m_pScene;

    m_pCameraController = 0;
    m_pEntity           = 0;
	m_pScene	        = 0;
	m_pViewport	        = 0;
}


void MeshViewerState::pause()
{
}


void MeshViewerState::resume()
{
}


void MeshViewerState::process()
{
}
