#include <MeshViewerState.h>
#include <Athena/Engine.h>
#include <Athena/Tasks/TaskManager.h>
#include <Athena/GameStates/GameStateManager.h>
#include <Athena-Entities/Scene.h>
#include <Athena-Entities/Entity.h>
#include <Athena-Entities/Transforms.h>
#include <Athena-Graphics/Visual/Camera.h>
#include <Athena-Graphics/Visual/World.h>
#include <Athena-Graphics/Visual/Object.h>
#include <Athena-Math/Vector3.h>
#include <Athena-Math/MathUtils.h>
#include <Ogre/OgreRoot.h>
#include <Ogre/OgreRenderTexture.h>
#include <Ogre/OgreRenderWindow.h>
#include <Ogre/OgreSceneManager.h>
#include <Ogre/OgreResourceGroupManager.h>


using namespace Athena;
using namespace Athena::Entities;
using namespace Athena::Graphics;
using namespace Athena::Graphics::Visual;
using namespace Athena::Math;


static const char* __CONTEXT__ = "Mesh Viewer State";


/***************************** CONSTRUCTION / DESTRUCTION ******************************/

MeshViewerState::MeshViewerState()
: m_pScene(0), m_pEntity(0), m_pCameraController(0), m_pCameraAxis(0), m_pCamera(0),
  m_pViewport(0)
{
}


MeshViewerState::~MeshViewerState()
{
}


/************************************** METHODS ****************************************/

bool MeshViewerState::loadMesh(const std::string& strFileName)
{
    if (m_pEntity)
    {
        m_pScene->destroy(m_pEntity);
        m_pEntity = 0;
    }

    Ogre::ResourceGroupManager* pManager = Ogre::ResourceGroupManager::getSingletonPtr();

    if (pManager->resourceGroupExists("Content"))
        pManager->destroyResourceGroup("Content");

    size_t offset = strFileName.find_last_of("/");

    pManager->createResourceGroup("Content");
    pManager->addResourceLocation(strFileName.substr(0, offset), "FileSystem", "Content");
    pManager->initialiseResourceGroup("Content");


    m_pEntity = m_pScene->create("Mesh");

    Visual::Object* pObject = new Visual::Object("Mesh", m_pEntity->getComponentsList());
    if (pObject->loadMesh(strFileName.substr(offset + 1)))
    {
        AxisAlignedBox aabb = fromOgre(pObject->getOgreEntity()->getWorldBoundingBox(true));

        Radian angle;
        if (m_pCamera->getAspectRatio() >= 1.0f)
            angle = m_pCamera->getFOVy() * 0.5f;
        else
            angle = m_pCamera->getFOVy() * m_pCamera->getAspectRatio() * 0.5f;

        m_pCameraController->getTransforms()->setPosition(aabb.getCenter());
        m_pCameraAxis->setPosition(0.0f, 0.0f, std::max(pObject->getOgreEntity()->getBoundingRadius() / MathUtils::Tan(angle),
                                                        pObject->getOgreEntity()->getBoundingRadius() + m_pCamera->getNearClipDistance()));

        //
        //         Vector3 size = aabb.getHalfSize();
        //
        //         Radian fovy = m_pCamera->getFOVy() * 0.5f;
        //         std::cout << __LINE__ << "fovy = " << fovy.valueDegrees() << std::endl;
        //         Real dy = size.y;
        //         std::cout << __LINE__ << "dy = " << dy << std::endl;
        //         Real dz1 = dy / MathUtils::Tan(fovy);
        //         std::cout << __LINE__ << "dz1 = " << dz1 << std::endl;
        //
        //         Radian fovx = fovy * m_pViewport->getActualWidth() / m_pViewport->getActualHeight();
        //         std::cout << __LINE__ << "fovx = " << fovx.valueDegrees() << std::endl;
        //         Real dx = size.x;
        //         std::cout << __LINE__ << "dx = " << dx << std::endl;
        //         Real dz2 = dx / MathUtils::Tan(fovx);
        //         std::cout << __LINE__ << "dz2 = " << dz2 << std::endl;
        //
        //         std::cout << __LINE__ << "size.z = " << size.z << std::endl;
        //
        // m_pCameraAxis->setPosition(0.0f, 0.0f, 1.1f * std::max(size.z, std::max(dz1, dz2)));
    }
}



/************************ METHODS TO BE OVERRIDEN BY EACH STATE ************************/

void MeshViewerState::enter()
{
    // Create the scene
    m_pScene = new Scene("MeshViewer");

    Visual::World* pVisualWorld = new Visual::World("", m_pScene->getComponentsList());

    Ogre::SceneManager* pSceneManager = pVisualWorld->createSceneManager(Ogre::ST_GENERIC);
    pSceneManager->setShadowTechnique(Ogre::SHADOWTYPE_STENCIL_ADDITIVE);
    pSceneManager->setShadowFarDistance(20.0f);

    pVisualWorld->setAmbientLight(Color(0.6f, 0.6f, 0.6f));

    m_pScene->show();

    // Create the camera and the viewport
    m_pCameraController = m_pScene->create("CameraController");

    m_pCameraAxis = new Transforms("CameraTransforms", m_pCameraController->getComponentsList());
    m_pCameraAxis->translate(0.0f, 0.0f, 10.0f);

    m_pCamera = new Camera("Camera", m_pCameraController->getComponentsList());
    m_pCamera->setTransforms(m_pCameraAxis);
    m_pCamera->setNearClipDistance(0.1f);
    m_pCamera->setFarClipDistance(1000.0f);
    m_pCamera->setFOVy(Degree(45.0f));

    Ogre::RenderWindow* pWindow = Engine::getSingletonPtr()->getMainWindow();

    m_pCamera->setAspectRatio(float(pWindow->getWidth()) / pWindow->getHeight());

    m_pViewport = m_pCamera->createViewport(pWindow);
    m_pViewport->setBackgroundColour(Ogre::ColourValue(0.1f, 0.1f, 0.1f));
}


void MeshViewerState::exit()
{
    Engine::getSingletonPtr()->getMainWindow()->removeViewport(0);

    delete m_pScene;

    m_pCameraController = 0;
    m_pCameraAxis       = 0;
    m_pCamera           = 0;
    m_pEntity           = 0;
    m_pScene            = 0;
    m_pViewport         = 0;
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
