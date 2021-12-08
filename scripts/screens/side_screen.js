'use strict';

class SideScreen extends Screen
{
	constructor(application)
	{
		super(application);

		location.hash = 'side_screen';

          	this.setHtml(document.getElementById("side_screen_html_id"));
	}
        enter()
        {
                this.setMessage('','red');
                this.show();
                this.showFooter();
                this.hideCanvas();
                this.get();

		this.handleButtons();

        }

	handleButtons()
	{
		console.log('SideScreen::handleButtons()');
		//set all buttons to none except schedule, logout, persons, edit profile so we can bring them up if role needs them
          	document.getElementById("side_games_id").style.display = "none";

		document.getElementById("side_schedule_id").style.display = "block";
               	document.getElementById("side_schedule_id").style.visibility = "visible";
		
		document.getElementById("side_logout_id").style.display = "block";
               	document.getElementById("side_logout_id").style.visibility = "visible";
		
		document.getElementById("side_managers_id").style.display = "none";
          	
		document.getElementById("side_club_administrator_id").style.display = "none";
		
		document.getElementById("side_persons_id").style.display = "block";
               	document.getElementById("side_persons_id").style.visibility = "visible";

          	document.getElementById("side_administration_id").style.display = "none";

		document.getElementById("side_profile_id").style.display = "block";
               	document.getElementById("side_profile_id").style.visibility = "visible";

		//loop throu array
		//not getting here......
		for (var i = 0; i < this.mApplication.mPersonArray.length; i++)
		{
			console.log('i:' + i);
			console.log('id:' + APPLICATION.getPersonId());
			if (this.mApplication.mPersonArray[i].mId == APPLICATION.getPersonId())
			{
				console.log('id in loop:' + APPLICATION.getPersonId());
				var player = this.mApplication.mPersonArray[i].mPlayerId;
				var family = this.mApplication.mPersonArray[i].mFamilyId;
				var coach = this.mApplication.mPersonArray[i].mCoachId;
				var manager = this.mApplication.mPersonArray[i].mManagerId;
				var administrator = this.mApplication.mPersonArray[i].mAdministratorId;

				if (player != null) 
				{
                			document.getElementById("side_games_id").style.display = "block";
                			document.getElementById("side_games_id").style.visibility = "visible";
				}
				if (family != null) 
				{
				}
				if (coach != null) 
				{
				}
				if (manager != null) 
				{
                			document.getElementById("side_managers_id").style.display = "block";
                			document.getElementById("side_managers_id").style.visibility = "visible";
				}
				if (administrator != null) 
				{
                			document.getElementById("side_club_administrator_id").style.display = "block";
                			document.getElementById("side_club_administrator_id").style.visibility = "visible";
                			
					document.getElementById("side_administration_id").style.display = "block";
                			document.getElementById("side_administration_id").style.visibility = "visible";
				}
			}
		}
	}

        execute()
        {
                this.processData();
                this.resetDataVariables();
        }

        exit()
        {
                this.hide();
                this.hideFooter();
                this.resetDataVariables();
                this.mApplication.setSideScreen(null);
        }


}
