'use strict';

class AddClubScreen
{
	constructor(application)
	{
		this.mApplication = application;

		location.hash = "add-club-screen";

		this.mCode = 0;

		//sql php vars
		this.mName = null;
		this.mAddress = null;
		
		document.getElementById("addclubscreenbuttonid").addEventListener("click",this.hit.bind(this));
	}

	hit()
	{
      		this.mName  = document.getElementById("add_club_screen_name_id").value;
               	this.mAddress = document.getElementById("add_club_screen_address_id").value;

		var url = "/php/classes/insert/insert_club.php?name=" + this.mName + "&address=" + this.mAddress; 

                var request = new XMLHttpRequest();
                request.onreadystatechange = function()
                {
                        if (request.readyState === XMLHttpRequest.DONE)
                        {
                                if (request.status === 200)
                                {
                                        var data = this.responseText;
                                        if (data)
                                        {
						APPLICATION.mAddClubScreen.mCode = data;
                                        }
                                }
                        }
                };

		var form = document.getElementById('add_club_screen_html_id');
		if (form.checkValidity() == true) 
		{
			request.open('POST', url);
                	request.send();
		}
	}
        
	show()
	{
              document.getElementById("add_club_screen_html_id").style.display = "block";
	}

	hide()
	{
              document.getElementById("add_club_screen_html_id").style.display = "none";
	}
}
