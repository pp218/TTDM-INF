global function TTDMStyle

const float TTDMIntroLength = 15.0

void function TTDMStyle(){
    Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always ) // 强制泰坦重生
	Riff_ForceTitanExitEnabled( eTitanExitEnabled.Never ) // 禁止离开泰坦
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	SetLoadoutGracePeriodEnabled( false )

	ClassicMP_SetCustomIntro( TTDMIntroSetup, TTDMIntroLength ) // TTDM入场方式
	ClassicMP_ForceDisableEpilogue( true ) // 关闭撤离
}

void function TTDMIntroSetup()
{
	// this should show intermission cam for 15 sec in prematch, before spawning players as titans
	AddCallback_GameStateEnter( eGameState.Prematch, TTDMIntroStart )
	AddCallback_OnClientConnected( TTDMIntroShowIntermissionCam )
}

void function TTDMIntroStart()
{
	thread TTDMIntroStartThreaded()
}

void function TTDMIntroStartThreaded()
{
	ClassicMP_OnIntroStarted()

	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsPrivateMatchSpectator( player ) )
			TTDMIntroShowIntermissionCam( player )
		else
			RespawnPrivateMatchSpectator( player )
	}

	wait TTDMIntroLength

	ClassicMP_OnIntroFinished()
}

void function TTDMIntroShowIntermissionCam( entity player )
{
	if ( GetGameState() != eGameState.Prematch )
		return

	thread PlayerWatchesTTDMIntroIntermissionCam( player )
}

void function PlayerWatchesTTDMIntroIntermissionCam( entity player )
{
	player.EndSignal( "OnDestroy" )
	ScreenFadeFromBlack( player )

	entity intermissionCam = GetEntArrayByClass_Expensive( "info_intermission" )[ 0 ]

	// the angle set here seems sorta inconsistent as to whether it actually works or just stays at 0 for some reason
	player.SetObserverModeStaticPosition( intermissionCam.GetOrigin() )
	player.SetObserverModeStaticAngles( intermissionCam.GetAngles() )
	player.StartObserverMode( OBS_MODE_STATIC_LOCKED )

	wait TTDMIntroLength

	RespawnAsTitan( player, false )
	TryGameModeAnnouncement( player )
}