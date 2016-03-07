class SquadSizeUpgrades_UIScreenListener extends UIScreenListener;

event OnReceiveFocus(UIScreen Screen)
{
	if(IsStrategyState())
    {
		GiveSoldierUnlock('SquadSizeIUnlock');
		GiveSoldierUnlock('SquadSizeIIUnlock');    
	}
}

function bool IsStrategyState()
{
    return `HQGAME != none && `HQPC != None && `HQPRES != none;
}

function GiveSoldierUnlock(Name UnlockName)
{
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	
	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	if (XComHQ.SoldierUnlockTemplates.Find(UnlockName) == INDEX_NONE) 
	{
		`log("Giving unlock: " @ UnlockName);

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("OTS Ability Unlock -" @ UnlockName);

		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	    NewGameState.AddStateObject(XComHQ);

		if(XComHQ.AddSoldierUnlockTemplate(NewGameState, X2SoldierUnlockTemplate(class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate(UnlockName))) )
		{
			`log("Unlock: " @ UnlockName);
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		}
		else
		{
			`log("Failed to unlock: " @ UnlockName);
			`XCOMHISTORY.CleanupPendingGameState(NewGameState);
		}
	} 
	else
	{
		`log("Already unlocked: " @ UnlockName);
	}
}