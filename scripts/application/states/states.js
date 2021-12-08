
'use strict';

class GLOBAL_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
                if (app.mStateLogs || app.mStateEnterLogs)
                {
                        console.log("GLOBAL_APPLICATION: ENTER"); 
                }
	}

        execute(app)
        {

                if (app.mStateLogs || app.mStateExecuteLogs)
                {
                        console.log("GLOBAL_APPLICATION: EXECUTE"); 
                }
		if (location.hash == '#login_screen' && app.mStateMachine.mCurrentState != app.mLOGIN_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mLOGIN_APPLICATION);
                }
		else if (location.hash == '#choose_person_screen' && app.mStateMachine.mCurrentState != app.mCHOOSE_PERSON_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mCHOOSE_PERSON_APPLICATION);
                }
		else if (location.hash == '#logout_screen' && app.mStateMachine.mCurrentState != app.mLOGOUT_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mLOGOUT_APPLICATION);
                }

		else if (location.hash == '#upcoming_screen' && app.mStateMachine.mCurrentState != app.mUPCOMING_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mUPCOMING_APPLICATION);
                }
		
		else if (location.hash == '#calendar_screen' && app.mStateMachine.mCurrentState != app.mCALENDAR_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mCALENDAR_APPLICATION);
                }
		
		else if (location.hash == '#rondo_screen' && app.mStateMachine.mCurrentState != app.mRONDO_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mRONDO_APPLICATION);
                }

		else if (location.hash == '#update_forgot_password_screen' && app.mStateMachine.mCurrentState != app.mUPDATE_FORGOT_PASSWORD_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mUPDATE_FORGOT_PASSWORD_APPLICATION);
                }
		else if (location.hash == '#insert_email_screen' && app.mStateMachine.mCurrentState != app.mINSERT_EMAIL_SCREEN_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_EMAIL_SCREEN_APPLICATION);
                }

		else if (location.hash == '#insert_native_login_screen' && app.mStateMachine.mCurrentState != app.mINSERT_NATIVE_LOGIN_SCREEN_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_NATIVE_LOGIN_SCREEN_APPLICATION);
                }

		else if (location.hash == '#insert_native_login_club_screen' && app.mStateMachine.mCurrentState != app.mINSERT_NATIVE_LOGIN_CLUB_SCREEN_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_NATIVE_LOGIN_CLUB_SCREEN_APPLICATION);
                }

		else if (location.hash == '#insert_club_screen' && app.mStateMachine.mCurrentState != app.mINSERT_CLUB_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_CLUB_APPLICATION);
                }

		else if (location.hash == '#insert_person_screen' && app.mStateMachine.mCurrentState != app.mINSERT_PERSON_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_PERSON_APPLICATION);
                }
		else if (location.hash == '#delete_person_screen' && app.mStateMachine.mCurrentState != app.mDELETE_PERSON_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mDELETE_PERSON_APPLICATION);
              	} 
		else if (location.hash == '#insert_team_screen' && app.mStateMachine.mCurrentState != app.mINSERT_TEAM_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_TEAM_APPLICATION);
                }
		else if (location.hash == '#insert_pitch_screen' && app.mStateMachine.mCurrentState != app.mINSERT_PITCH_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_PITCH_APPLICATION);
                }
		else if (location.hash == '#insert_practice_screen' && app.mStateMachine.mCurrentState != app.mINSERT_PRACTICE_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_PRACTICE_APPLICATION);
                }
		else if (location.hash == '#insert_game_screen' && app.mStateMachine.mCurrentState != app.mINSERT_GAME_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_GAME_APPLICATION);
                }
		else if (location.hash == '#insert_forgot_password_screen' && app.mStateMachine.mCurrentState != app.mINSERT_FORGOT_PASSWORD_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_FORGOT_PASSWORD_APPLICATION);
                }
		else if (location.hash == '#invite_to_club_screen' && app.mStateMachine.mCurrentState != app.mINVITE_TO_CLUB_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINVITE_TO_CLUB_APPLICATION);
                }
		else if (location.hash == '#club_profile_screen' && app.mStateMachine.mCurrentState != app.mCLUB_PROFILE_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mCLUB_PROFILE_APPLICATION);
                }
		else if (location.hash == '#insert_accept_club_invite_screen' && app.mStateMachine.mCurrentState != app.mINSERT_ACCEPT_CLUB_INVITE_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_ACCEPT_CLUB_INVITE_APPLICATION);
                }
		else if (location.hash == '#delete_club_screen' && app.mStateMachine.mCurrentState != app.mDELETE_CLUB_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mDELETE_CLUB_APPLICATION);
              	} 
	
		//profile
		else if (location.hash == '#profile_screen' && app.mStateMachine.mCurrentState != app.mPROFILE_APPLICATION)
                {
                        APPLICATION.mStateMachine.changeState(APPLICATION.mPROFILE_APPLICATION);
                }
	}

        exit(application)
        {
                if (application.mStateLogs || application.mStateExitLogs)
		{
                        console.log("GLOBAL_APPLICATION: EXIT"); 
                }
	}
}





class INIT_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(application)
        {
		if (application.mStateLogs || application.mStateEnterLogs)
		{
			console.log("INIT_APPLICATION_STATE: ENTER");        
		}

		if (application.getInsertEmailScreenHtml())
		{
			application.getInsertEmailScreenHtml().style.display = "none";
		}
		
		if (application.getInsertNativeLoginScreenHtml())
		{
			application.getInsertNativeLoginScreenHtml().style.display = "none";
		}
		
		if (application.getLoginScreenHtml())
		{
			application.getLoginScreenHtml().style.display = "none";
		}
		
		if (application.getChoosePersonScreenHtml())
		{
			application.getChoosePersonScreenHtml().style.display = "none";
		}
		
		if (application.getUpcomingScreenHtml())
		{
			application.getUpcomingScreenHtml().style.display = "none";
		}

		if (application.getCalendarScreenHtml())
		{
			application.getCalendarScreenHtml().style.display = "none";
		}

		if (application.getRondoScreenHtml())
		{
			application.getRondoScreenHtml().style.display = "none";
		}
		
		if (application.getInsertClubScreenHtml())
		{
			application.getInsertClubScreenHtml().style.display = "none";
		}
		
		if (application.getDeleteClubScreenHtml())
		{
			application.getDeleteClubScreenHtml().style.display = "none";
		}
		
		if (application.getInsertPersonScreenHtml())
		{
			application.getInsertPersonScreenHtml().style.display = "none";
		}
		
		if (application.getDeletePersonScreenHtml())
		{
			application.getDeletePersonScreenHtml().style.display = "none";
		}
		
		if (application.getInsertTeamScreenHtml())
		{
			application.getInsertTeamScreenHtml().style.display = "none";
		}
		
		if (application.getInsertPitchScreenHtml())
		{
			application.getInsertPitchScreenHtml().style.display = "none";
		}
		
		if (application.getInsertPracticeScreenHtml())
		{
			application.getInsertPracticeScreenHtml().style.display = "none";
		}
		
		if (application.getInsertGameScreenHtml())
		{
			application.getInsertGameScreenHtml().style.display = "none";
		}
		
		if (application.getInsertForgotPasswordScreenHtml())
		{
			application.getInsertForgotPasswordScreenHtml().style.display = "none";
		}
		
		if (application.getInviteToClubScreenHtml())
		{
			application.getInviteToClubScreenHtml().style.display = "none";
		}
		if (application.getClubProfileScreenHtml())
		{
			application.getClubProfileScreenHtml().style.display = "none";
		}
		
		if (application.getInsertAcceptClubInviteScreenHtml())
		{
			application.getInsertAcceptClubInviteScreenHtml().style.display = "none";
		}

		if (application.getUpdateForgotPasswordScreenHtml())
		{
			application.getUpdateForgotPasswordScreenHtml().style.display = "none";
		}

		//profile	
		if (application.getProfileScreenHtml())
		{
			application.getProfileScreenHtml().style.display = "none";
		}
	}
        
	execute(application)
        {
		if (application.mStateLogs || application.mStateExecuteLogs)
		{
			console.log("INIT_APPLICATION_STATE: EXECUTE");        
		}
		if (application.mInsertNativeLoginToken)
		{
			application.mStateMachine.changeState(application.mINSERT_NATIVE_LOGIN_SCREEN_APPLICATION);
		}
		else if (application.mJoinEmail)
		{
			application.mStateMachine.changeState(application.mINSERT_NATIVE_LOGIN_SCREEN_APPLICATION);
		}
		else if (application.mForgotPasswordToken)
		{
			application.mStateMachine.changeState(application.mUPDATE_FORGOT_PASSWORD_APPLICATION);
		}
		else if (application.getJWT())
		{
			application.mStateMachine.changeState(application.mUPCOMING_APPLICATION);
		}
		else
		{
			application.mStateMachine.changeState(application.mLOGIN_APPLICATION);
		}
	}

        exit(application)
        {
		if (application.mStateLogs || application.mStateExitLogs)
		{
			console.log("INIT_APPLICATION_STATE: EXIT");        
		}
	}
}

class LOGIN_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("LOGIN_APPLICATION: ENTER");        
		}

		app.setCurrentScreen(new LoginScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("LOGIN_APPLICATION: EXECUTE");        
		}

		app.getCurrentScreen().execute()
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("LOGIN_APPLICATION: EXIT");        
		}
		app.mCurrentScreen.exit();
	}
}

class CHOOSE_PERSON_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("CHOOSE_PERSON_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new ChoosePersonScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("CHOOSE_PERSON_APPLICATION: EXECUTE");        
		}
		
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("CHOOSE_PERSON_APPLICATION: EXIT");        
		}
		app.getCurrentScreen().exit();
	}
}


class LOGOUT_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("LOGOUT_APPLICATION: ENTER");        
		}

		// no logout class so 
		//
                //clear mJWT from localstorage
                localStorage.removeItem("mJWT");

		app.mUserSelectedPerson = false;

		app.googleSignOut();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("LOGOUT_APPLICATION: EXECUTE");        
		}
		app.mStateMachine.changeState(app.mINIT_APPLICATION);
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("LOGOUT_APPLICATION: EXIT");        
		}

		location.hash = "login_screen";
	}
}

class INSERT_EMAIL_SCREEN_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("INSERT_EMAIL_SCREEN_APPLICATION: ENTER");        
		}

		app.setCurrentScreen(new InsertEmailScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("INSERT_EMAIL_SCREEN_APPLICATION: EXECUTE");        
		}
		
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("INSERT_EMAIL_SCREEN_APPLICATION: EXIT");        
		}
		app.getCurrentScreen().exit();
	}
}

class INSERT_FORGOT_PASSWORD_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("INSERT_FORGOT_PASSWORD_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new InsertForgotPasswordScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("INSERT_FORGOT_PASSWORD_APPLICATION: EXECUTE");        
		}

		app.getCurrentScreen().execute();

	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("INSERT_FORGOT_PASSWORD_APPLICATION: EXIT");        
		}

		app.getCurrentScreen().exit();

	}
}

class INVITE_TO_CLUB_APPLICATION extends State
{
        constructor()
        {
                super();
        }

        enter(app)
        {
                if (app.mStateLogs || app.mStateEnterLogs)
                {
                        console.log("INVITE_TO_CLUB_APPLICATION: ENTER");
		}

		app.setCurrentScreen(new InviteToClubScreen(app));
		app.getCurrentScreen().enter();
        }

        execute(app)
        {
                if (app.mStateLogs || app.mStateExecuteLogs)
                {
                        console.log("INVITE_TO_CLUB_APPLICATION: EXECUTE");
                }
		app.getCurrentScreen().execute();
        }

        exit(app)
        {
                if (app.mStateLogs || app.mStateExitLogs)
                {
                        console.log("INVITE_TO_CLUB_APPLICATION: EXIT");
                }
		app.getCurrentScreen().exit();
        }
}

//CLUB PROFILE
class CLUB_PROFILE_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("CLUB_PROFILE_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new ClubProfileScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("CLUB_PROFILE_APPLICATION: EXECUTE");        
		}
		
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("CLUB_PROFILE_APPLICATION: EXIT");        
		}
		
		app.getCurrentScreen().exit();
	}
}

class INSERT_ACCEPT_CLUB_INVITE_APPLICATION extends State
{
        constructor()
        {
                super();
        }

        enter(app)
        {
                if (app.mStateLogs || app.mStateEnterLogs)
                {
                        console.log("INSERT_ACCEPT_CLUB_INVITE_APPLICATION: ENTER");
		}
		
		app.setCurrentScreen(new InsertAcceptClubInviteScreen(app));
		app.getCurrentScreen().enter();
        }
        
	execute(app)
        {
                if (app.mStateLogs || app.mStateExecuteLogs)
                {
                        console.log("INSERT_ACCEPT_CLUB_INVITE_APPLICATION: EXECUTE");
                }
		app.getCurrentScreen().execute();
	}
        exit(app)
        {
                if (app.mStateLogs || app.mStateExitLogs)
                {
                        console.log("INSERT_ACCEPT_CLUB_INVITE_APPLICATION: EXIT");
                }
		app.getCurrentScreen().exit();
        }
}
//what
//
class UPDATE_FORGOT_PASSWORD_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("UPDATE_FORGOT_PASSWORD_APPLICATION: ENTER");        
		}

		app.setCurrentScreen(new UpdateForgotPasswordScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("UPDATE_FORGOT_PASSWORD_APPLICATION: EXECUTE");        
		}
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("UPDATE_FORGOT_PASSWORD_APPLICATION: EXIT");        
		}
		app.getCurrentScreen().exit();
	}
}

class UPCOMING_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("UPCOMING_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new UpcomingScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("UPCOMING_APPLICATION: EXECUTE");        
		}
		
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("UPCOMING_APPLICATION: EXIT");        
		}
		
		app.getCurrentScreen().exit();
	}
}

class CALENDAR_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("CALENDAR_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new CalendarScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("CALENDAR_APPLICATION: EXECUTE");        
		}
		
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("CALENDAR_APPLICATION: EXIT");        
		}


		
		if (app.getCurrentScreen().mCloneArray)
		{
			for (i = 0; i < app.getCurrentScreen().mCloneArray.length; i++)
			{
				app.getCurrentScreen().mCloneArray[i].remove();
			}
		}
		app.getCurrentScreen().exit();
	}
}

class RONDO_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("RONDO_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new RondoScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("RONDO_APPLICATION: EXECUTE");        
		}
		
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("RONDO_APPLICATION: EXIT");        
		}
		
		app.getCurrentScreen().exit();
	}
}

class INSERT_CLUB_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("INSERT_CLUB_APPLICATION: ENTER");        
		}

		app.setCurrentScreen(new InsertClubScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("INSERT_CLUB_APPLICATION: EXECUTE");        
		}

		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("INSERT_CLUB_APPLICATION: EXIT");        
		}

		app.getCurrentScreen().exit();
	}
}

class INSERT_PERSON_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("INSERT_PERSON_APPLICATION: ENTER");        
		}

		app.setCurrentScreen(new InsertPersonScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("INSERT_PERSON_APPLICATION: EXECUTE");        
		}

		app.getCurrentScreen().execute();
	}

        exit(app)
	{
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("INSERT_PERSON_APPLICATION: EXIT");        
		}
		app.getCurrentScreen().exit();
	}
}

class INSERT_NATIVE_LOGIN_SCREEN_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("INSERT_NATIVE_LOGIN_SCREEN_APPLICATION: ENTER");        
		}

		app.setCurrentScreen(new InsertNativeLoginScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("INSERT_NATIVE_LOGIN_SCREEN_APPLICATION: EXECUTE");        
		}
		
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("INSERT_NATIVE_LOGIN_SCREEN_APPLICATION: EXIT");        
		}
		app.getCurrentScreen().exit();
	}
}

class DELETE_PERSON_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("DELETE_PERSON_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new DeletePersonScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("DELETE_PERSON_APPLICATION: EXECUTE");        
		}
		
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("DELETE_PERSON_APPLICATION: EXIT");        
		}
		
		app.getCurrentScreen().exit();
	}
}

class DELETE_CLUB_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("DELETE_CLUB_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new DeleteClubScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("DELETE_CLUB_APPLICATION: EXECUTE");        
		}
		
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("DELETE_CLUB_APPLICATION: EXIT");        
		}
		
		app.getCurrentScreen().exit();
	}
}

class INSERT_TEAM_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("INSERT_TEAM_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new InsertTeamScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("INSERT_TEAM_APPLICATION: EXECUTE");        
		}

		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("INSERT_TEAM_APPLICATION: EXIT");        
		}
		app.getCurrentScreen().exit();
	}
}


class INSERT_PITCH_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("INSERT_PITCH_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new InsertPitchScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("INSERT_PITCH_APPLICATION: EXECUTE");        
		}

		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("INSERT_PITCH_APPLICATION: EXIT");        
		}
		app.getCurrentScreen().exit();
	}
}


class INSERT_PRACTICE_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("INSERT_PRACTICE_APPLICATION: ENTER");        
		}

                app.setCurrentScreen(new InsertPracticeScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("INSERT_PRACTICE_APPLICATION: EXECUTE");        
		}

		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("INSERT_PRACTICE_APPLICATION: EXIT");        
		}

		app.getCurrentScreen().exit();
	}
}

class INSERT_GAME_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("INSERT_GAME_APPLICATION: ENTER");        
		}
                
		app.setCurrentScreen(new InsertGameScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("INSERT_GAME_APPLICATION: EXECUTE");        
		}

		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("INSERT_GAME_APPLICATION: EXIT");        
		}
		
		app.getCurrentScreen().exit();
	}
}

//PROFILE
class PROFILE_APPLICATION extends State
{
	constructor() 
	{
		super();
	}

        enter(app)
        {
		if (app.mStateLogs || app.mStateEnterLogs)
		{
			console.log("PROFILE_APPLICATION: ENTER");        
		}
		
		app.setCurrentScreen(new ProfileScreen(app));
		app.getCurrentScreen().enter();
	}

        execute(app)
        {
		if (app.mStateLogs || app.mStateExecuteLogs)
		{
			console.log("PROFILE_APPLICATION: EXECUTE");        
		}
		
		app.getCurrentScreen().execute();
	}

        exit(app)
        {
		if (app.mStateLogs || app.mStateExitLogs)
		{
			console.log("PROFILE_APPLICATION: EXIT");        
		}
		
		app.getCurrentScreen().exit();
	}
}
