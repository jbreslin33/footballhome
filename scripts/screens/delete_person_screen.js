'use strict';

class DeletePersonScreen extends Screen
{
	constructor(application)
	{
		super(application);

		location.hash = "delete_person_screen";

		//html ids 
		this.mSpinnerId = "delete_person_screen_spinner_id";
		this.mHtmlId = "delete_person_screen_html_id";

		//sql php vars
		this.mEmail = null;
		
		document.getElementById("deletepersonscreenbuttonid").onclick = this.hit.bind(this);
	}

	get()
	{
		if (APPLICATION.getJWT())
		{
			var select = document.getElementById("person_select_id");
                	var person_id = select.options[select.selectedIndex].value;
			var url = "/php/classes/select/select_persons.php?jwt=" + APPLICATION.getJWT(); 
		        var request = new XMLHttpRequest();
                	request.onreadystatechange = function()
                	{
                        	if (request.readyState === XMLHttpRequest.DONE)
                        	{
                                	if (request.status === 200)
                                	{
						console.log('response:' + this.responseText);
                                        	APPLICATION.mDeletePersonScreen.mData = this.responseText;
                                	}
                        	}
                	};

                        request.open('POST', url);
                        request.send();
		}
	}

	hit()
	{
		this.mHit = true;

		var select = document.getElementById("delete_person_screen_select_id");
                var person_id = select.options[select.selectedIndex].value;
		var url = "/php/classes/delete/delete_person.php?name=" + "&jwt=" + APPLICATION.getJWT() + '&person_id=' + person_id;

                var request = new XMLHttpRequest();
                request.onreadystatechange = function()
                {
                        if (request.readyState === XMLHttpRequest.DONE)
                        {
                                if (request.status === 200)
                                {
					APPLICATION.mDeletePersonScreen.mData = this.responseText;
                                }
                        }
                };
		request.open('POST', url);
                request.send();
	}
}
