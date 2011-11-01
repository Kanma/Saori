#import <Athena/GameStates/IGameState.h>


class MeshViewerState: public Athena::GameStates::IGameState
{
		//_____ Construction / Destruction __________
public:
	MeshViewerState();
	virtual ~MeshViewerState();


	//_____ Methods __________
public:
    bool loadMesh(const std::string& strFileName);
    
	
	//_____ Methods to be overriden by each state __________
public:
	virtual void enter();
	virtual void exit();
	virtual void pause();
	virtual void resume();

	virtual void process();


	//_____ Attributes __________
private:
	Athena::Entities::Entity* m_pEntity;
};
