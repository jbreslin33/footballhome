'use strict';

class LoginScreen extends Screen
{
	constructor(application)
	{
		super(application);
	
    		location.hash = 'login_screen';

		//sql php vars
		this.mEmail = null;
		this.mPassword = null;
		this.mGoogleID = null;	
		this.mGoogleIDToken = null;	
		this.mFirstName = null;	
		this.mLastName = null;	
		this.mImageUrl = null;	

		document.getElementById("loginscreenbuttonid").addEventListener("click",this.hit.bind(this));

                this.setHtml(document.getElementById("login_screen_html_id"));
		this.setMenuItem(document.getElementById("login_nav_id"));
               	this.setMessageElement(document.getElementById("login_screen_message_id"));
                this.setSpinner(document.getElementById("login_screen_spinner_id"));
                
		this.setForm(document.getElementById("login_screen_form_id"));

		this.mGoogleLoginHit = false;
	}

	hit()
	{
                this.mEmail    = document.getElementById("login_screen_email_id").value;
                this.mPassword  = document.getElementById("login_screen_password_id").value;

		this.setUrl("/php/classes/screens/native_login.php?email=" + this.mEmail + "&password=" + this.mPassword); 

		this.ajax();
	}

	//overide from screen
	checkValidity()
	{
		if (APPLICATION.getCurrentScreen().mGoogleLoginHit)
		{
			APPLICATION.getCurrentScreen().send();
		}
		else
		{
			super.checkValidity();
		}
	}
       
        googleLogin()
        {
		APPLICATION.getCurrentScreen().mGoogleLoginHit = true;
                this.setUrl("/php/classes/screens/google_login.php?email=" + this.mEmail + "&google_id=" + this.mGoogleID + "&id_token=" + this.mIDToken + "&first_name=" + this.mFirstName + "&last_name=" + this.mLastName);

		this.ajax();
        }

	googleSignIn(googleUser)
	{
        	// Useful data for your client-side scripts:
        	var profile = googleUser.getBasicProfile();

        	// The ID token you need to pass to your backend:
        	var id_token = googleUser.getAuthResponse().id_token;
	
		APPLICATION.getCurrentScreen().mEmail = profile.getEmail();	
		APPLICATION.getCurrentScreen().mGoogleID = profile.getId();	
		APPLICATION.getCurrentScreen().mIDToken = id_token;	
		APPLICATION.getCurrentScreen().mFirstName = profile.getGivenName();	
		APPLICATION.getCurrentScreen().mLastName = profile.getFamilyName();	
		APPLICATION.getCurrentScreen().mImageUrl = profile.getImageUrl();	

		this.googleLogin();
	}

	googleSignOut()
	{
        	var auth2 = gapi.auth2.getAuthInstance();
        	auth2.signOut().then(function ()
        	{
                	console.log('User signed out.');
        	});
	}

	processCodes()
        {
                if (this.mJson.codes)
                {
                        var code = 0;
                        for (var i = 0; i < this.mJson.codes.length; i++)
                        {
                                code = this.mJson.codes[i].code;
                        }
                        //definite success so send to main
                        if (code == '-100')
                        {
                                if (this.mApplication.mStateMachine.currentState() == this.mApplication.mCHOOSE_PERSON_APPLICATION)
                                {
                                        //do nothing
                                }
                                else
                                {
                                        this.mApplication.mStateMachine.changeState(this.mApplication.mCHOOSE_PERSON_APPLICATION);
                                }
                        }
                        else if (code == '-101')
                        {
                                //standard error code so stay in state and display message if their is one.
                        }
                }
        }
}
