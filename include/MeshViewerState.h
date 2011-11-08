#import <Athena/GameStates/IGameState.h>
#import <controls/View3D.h>
#import <controls/ToolPanel.h>
#import <controls/ResourcesPanel.h>


class MeshViewerState: public Athena::GameStates::IGameState
{
		//_____ Construction / Destruction __________
public:
    MeshViewerState(NSView* workingZone, ToolPanel* toolPanel);
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
    // UI
    NSView*         m_workingZone;
    ToolPanel*      m_toolPanel;
    View3D*         m_view3D;

	Athena::Entities::Entity* m_pEntity;
};
