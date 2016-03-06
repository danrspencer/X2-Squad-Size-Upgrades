class SquadSizeUpgrades_UIScreenListener extends UIScreenListener;

var XComGameState_HeadquartersXCom XComHQ;

event OnReceiveFocus(UIScreen Screen)
{
	if(IsStrategyState())
    {
		XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

		if (!UnlockedExtraSlot1()) 
		{
			`log("Giving unlock SquadSizeIUnlock");
			GiveSoldierUnlock('SquadSizeIUnlock');
		}

		if (!UnlockedExtraSlot2())
		{ 
			`log("Giving unlock SquadSizeIIUnlock");
			GiveSoldierUnlock('SquadSizeIIUnlock');    
		}
	}
}

function bool IsStrategyState()
{
    return `HQGAME != none && `HQPC != None && `HQPRES != none;
}

function bool UnlockedExtraSlot1()
{
	return XComHQ.SoldierUnlockTemplates.Find('SquadSizeIUnlock') != INDEX_NONE;
}

function bool UnlockedExtraSlot2()
{
	return XComHQ.SoldierUnlockTemplates.Find('SquadSizeIIUnlock') != INDEX_NONE;
}

function GiveSoldierUnlock(Name UnlockName)
{
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;

	if(XComHQ.AddSoldierUnlockTemplate(NewGameState, X2SoldierUnlockTemplate(class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate(UnlockName))) )
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
	}
}