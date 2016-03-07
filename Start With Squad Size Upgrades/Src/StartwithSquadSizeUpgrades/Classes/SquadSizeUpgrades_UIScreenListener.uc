class SquadSizeUpgrades_UIScreenListener extends UIScreenListener;

event OnReceiveFocus(UIScreen Screen)
{
	if(IsStrategyState() && IsNotAlreadyUnlocked())
    {
		`log("Unlocking Squad Size Upgrades");

		MakeSquadSizeUpgradesFree();

		GiveSoldierUnlock('SquadSizeIUnlock');
		GiveSoldierUnlock('SquadSizeIIUnlock');

		HideSquadSizeUpgrades();
	}
}

function bool IsStrategyState()
{
    return `HQGAME != none && `HQPC != None && `HQPRES != none;
}

function bool IsNotAlreadyUnlocked()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	
	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	return XComHQ.SoldierUnlockTemplates.Find('SquadSizeIUnlock') == INDEX_NONE && XComHQ.SoldierUnlockTemplates.Find('SquadSizeIIUnlock') == INDEX_NONE;
}

function GiveSoldierUnlock(Name UnlockName)
{
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	
	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

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

function HideSquadSizeUpgrades()
{
	local X2StrategyElementTemplateManager templateManager;
	local X2FacilityTemplate officerSchoolTemplate;

	`log("Delete squad size upgrades from officer school template");

	templateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	officerSchoolTemplate = X2FacilityTemplate(templateManager.FindStrategyElementTemplate('OfficerTrainingSchool'));

	officerSchoolTemplate.SoldierUnlockTemplates.RemoveItem('SquadSizeIUnlock');
	officerSchoolTemplate.SoldierUnlockTemplates.RemoveItem('SquadSizeIIUnlock');
}

function MakeSquadSizeUpgradesFree()
{
	local X2StrategyElementTemplateManager templateManager;
    local X2FacilityTemplate officerSchoolTemplate;

	`log("Replacing existing squad size upgrades with free ones");

    templateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
    templateManager.AddStrategyElementTemplate(FreeSquadSizeUnlock('SquadSizeIUnlock'), true);
    templateManager.AddStrategyElementTemplate(FreeSquadSizeUnlock('SquadSizeIIUnlock'), true);
}

function X2SoldierUnlockTemplate FreeSquadSizeUnlock(Name UnlockName)
{
	local X2SoldierUnlockTemplate Template;

	`CREATE_X2TEMPLATE(class'X2SoldierUnlockTemplate', Template, UnlockName);

	return Template;
}