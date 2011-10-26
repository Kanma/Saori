#ifndef _MESHVIEWERSTATE_H_
#define _MESHVIEWERSTATE_H_

#include <Athena/GameStates/IGameState.h>


class MeshViewerState: public Athena::GameStates::IGameState
{
		//_____ Construction / Destruction __________
public:
	MeshViewerState();
	virtual ~MeshViewerState();


	//_____ Methods __________
public:
    
	
	//_____ Methods to be overriden by each state __________
public:
	virtual void enter();
	virtual void exit();
	virtual void pause();
	virtual void resume();

	virtual void process();


	//_____ Attributes __________
private:
	Athena::Entities::Scene*  m_pScene;
	Athena::Entities::Entity* m_pEntity;
    Athena::Entities::Entity* m_pCameraController;
    Ogre::Viewport*           m_pViewport;
};

#endif
