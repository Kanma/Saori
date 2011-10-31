#import <controls/View3D.h>
#import <Athena-Graphics/Visual/World.h>
#import <Athena-Graphics/Visual/Object.h>
#import <Athena-Math/Vector3.h>
#import <Athena-Math/MathUtils.h>
#import <Ogre/OgreSceneManager.h>
#include <Ogre/OgreRenderWindow.h>


using namespace Athena;
using namespace Athena::Entities;
using namespace Athena::Graphics;
using namespace Athena::Graphics::Visual;
using namespace Athena::Math;


@implementation View3D

/************************************** PROPERTIES **************************************/

- (Scene*) scene
{
    return pScene;
}


- (void) setAspectRatio:(Real)value
{
    assert(pCamera);
    
    pCamera->setAspectRatio(value);
}


- (Real) aspectRatio
{
    assert(pCamera);
    
    return pCamera->getAspectRatio();
}


- (void) setPolygonMode:(Ogre::PolygonMode)mode
{
    assert(pCamera);
    
    pCamera->setPolygonMode(mode);
}


- (Ogre::PolygonMode) polygonMode
{
    assert(pCamera);
    
    return pCamera->getPolygonMode();
}


- (void) setLightEnabled:(BOOL)enabled
{
    assert(pCameraLight);
    
    pCameraLight->getOgreLight()->setVisible(enabled == YES);
}


- (BOOL) lightEnabled
{
    assert(pCameraLight);
    
    return (pCameraLight->getOgreLight()->getVisible() == YES);
}


- (void) setLightColor:(Athena::Math::Color)color
{
    assert(pCameraLight);
    
    pCameraLight->setDiffuseColor(color);
}


- (Athena::Math::Color) lightColor
{
    assert(pCameraLight);
    
    return pCameraLight->getDiffuseColor();
}


/*************************************** METHODS ****************************************/

- (id) initWithRenderWindow:(Ogre::RenderWindow*)window
{
    if (self = [super init])
    {
        pWindow = window;
        
        // Create the scene
        pScene = new Scene("MeshViewer");

        Visual::World* pVisualWorld = new Visual::World("", pScene->getComponentsList());

        Ogre::SceneManager* pSceneManager = pVisualWorld->createSceneManager(Ogre::ST_GENERIC);
        pSceneManager->setShadowTechnique(Ogre::SHADOWTYPE_STENCIL_ADDITIVE);
        pSceneManager->setShadowFarDistance(20.0f);

        pVisualWorld->setAmbientLight(Color(0.5f, 0.5f, 0.5f));

        pScene->show();

        // Create the camera and the viewport
        pCameraController = pScene->create("CameraController");

        pCameraAxis = new Transforms("CameraTransforms", pCameraController->getComponentsList());
        pCameraAxis->translate(0.0f, 0.0f, 10.0f);

        pCamera = new Camera("Camera", pCameraController->getComponentsList());
        pCamera->setTransforms(pCameraAxis);
        pCamera->setNearClipDistance(0.1f);
        pCamera->setFarClipDistance(1000.0f);
        pCamera->setFOVy(Degree(45.0f));

        pCameraLight = new PointLight("Light", pCameraController->getComponentsList());
        pCameraLight->setTransforms(pCameraAxis);
        pCameraLight->setDiffuseColor(Color(0.7f, 0.7f, 0.7f, 0.7f));

        pCamera->setAspectRatio(float(window->getWidth()) / window->getHeight());

        pViewport = pCamera->createViewport(window);
        pViewport->setBackgroundColour(Ogre::ColourValue(0.1f, 0.1f, 0.1f));
    }

    return self;
}


- (void) dealloc
{
    pWindow->removeViewport(0);

    delete pScene;

    [super dealloc];
}


- (void) translateBy:(const Athena::Math::Vector3&)offset
{
    assert(pCameraAxis);
    assert(pCameraController);
    
    pCameraAxis->translate(0.0f, 0.0f, offset.z);
    pCameraController->getTransforms()->translate(offset.x, offset.y, 0.0f);
}


- (void) rotateBy:(const Athena::Math::Quaternion&)quat
{
    assert(pCameraController);
    
    pCameraController->getTransforms()->rotate(quat);
}


- (void) rotateBy:(const Athena::Math::Degree&)angle around:(const Athena::Math::Vector3&)axis
{
    assert(pCameraAxis);
    assert(pCameraController);
    
    pCameraController->getTransforms()->rotate(axis, angle);
}


- (void) frameAll
{
    // Assertions
    assert(pScene);
    
    // Declarations
    AxisAlignedBox boundingBox;
    float boundingRadius = 0.0f;

    // Compute the bounding box and radius of the whole scene
    Scene::tEntitiesIterator iter = pScene->getEntitiesIterator();
    while (iter.hasMoreElements())
    {
        Entity* pEntity = iter.getNext();
        ComponentsList::tComponentsIterator iter2 = pEntity->getComponentsIterator();
        while (iter2.hasMoreElements())
        {
            Entities::Component* pComponent = iter2.getNext();
            if (pComponent->getType() == Object::TYPE)
            {
                Ogre::Entity* pOgreEntity = Object::cast(pComponent)->getOgreEntity();
                boundingBox.merge(fromOgre(pOgreEntity->getWorldBoundingBox(true)));
                boundingRadius = std::max(boundingRadius, pOgreEntity->getBoundingRadius());
            }
        }
    }
    
    Radian angle;
    if (pCamera->getAspectRatio() >= 1.0f)
        angle = pCamera->getFOVy() * 0.5f;
    else
        angle = pCamera->getFOVy() * pCamera->getAspectRatio() * 0.5f;

    pCameraController->getTransforms()->setPosition(boundingBox.getCenter());
    pCameraAxis->setPosition(0.0f, 0.0f, std::max(boundingRadius / MathUtils::Tan(angle),
                                                  boundingRadius + pCamera->getNearClipDistance()));
    pCameraAxis->setDirection(Vector3::NEGATIVE_UNIT_Z);
}

@end
