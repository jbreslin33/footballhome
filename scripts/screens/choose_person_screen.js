'use strict';
      
class ChoosePersonScreen extends Screen
{
	constructor(application)
	{
                super(application);

                location.hash = 'choose_person_screen';

                this.setHtml(document.getElementById("choose_person_screen_html_id"));
                this.setColSixHtml(document.getElementById("choose_person_screen_col_6_html_id"));
                this.setMessageElement(document.getElementById("choose_person_screen_message_id"));
                this.setForm(document.getElementById("choose_person_screen_form_id"));
                this.setSpinner(document.getElementById("choose_person_screen_spinner_id"));
                        
                this.setFamilySelect(document.getElementById("choose_person_screen_family_select_id"));
                this.setPersonSelect(document.getElementById("choose_person_screen_select_id"));

		this.mPersonsExists = -1;
		this.mFamiliesExists = -1;

                //person select
                if (this.getPersonSelect())
                {
                        this.getPersonSelect().onchange = this.personSelected.bind(this);
                }

                this.getForm().addEventListener('submit', function(e)
                {
                        e.preventDefault();
                        APPLICATION.getCurrentScreen().hit();
                });
	}

	get()
	{
		APPLICATION.getCurrentScreen().setUrl("/php/classes/screens/select_families.php?jwt=" + APPLICATION.getJWT()); 
                APPLICATION.getCurrentScreen().ajax();
	}

	getPersons()
	{
		APPLICATION.getCurrentScreen().setUrl("/php/classes/screens/select_persons.php?" + this.getStandardParameters()); 
                APPLICATION.getCurrentScreen().ajax();
	}

        personSelected()
        {
		APPLICATION.setPersonId(this.getPersonSelect().value);
               
		if (APPLICATION.getSideScreen())
                {
                        APPLICATION.getSideScreen().handleButtons();
                }

                //change to current state as we switched person so we need to reload screen
                //APPLICATION.mStateMachine.changeState(APPLICATION.mStateMachine.mCurrentState);
        }

	hit()
	{
		//set id on application for saving
		console.log('this.getPersonSelect().value:' + this.getPersonSelect().value);

		this.mApplication.setPersonId(this.getPersonSelect().value);

		APPLICATION.getCurrentScreen().setUrl("/php/classes/screens/choose_person.php?" +  this.getStandardParameters());
                APPLICATION.getCurrentScreen().ajax();

		this.mApplication.mUserSelectedPerson = true;
	}

	hitChoosePerson()
	{
		var screen = APPLICATION.getCurrentScreen();
		

		//set id on application for saving
		APPLICATION.setPersonId(this.getAttribute('id'));
		console.log('this.getAttribute id:' + this.getAttribute('id'));

		screen.setUrl("/php/classes/screens/choose_person.php?" +  screen.getStandardParameters());
                screen.ajax();

		APPLICATION.mUserSelectedPerson = true;
	}

	enter()
	{
   		this.mApplication.showLoggedInHeaderHtml(false);
		super.enter();
	}

        execute()
        {
		super.execute();

		if (this.mFamiliesExist == 0)
		{
                	//APPLICATION.mStateMachine.changeState(APPLICATION.mINSERT_FAMILY_APPLICATION);
		}
        }

	exit()
	{
   		this.mApplication.showLoggedInHeaderHtml(true);
		super.exit();
	}

        processFamilies()
        {

                if (this.mJson.families)
                {
                        //load up persons option
                        var select = this.getFamilySelect();
                        select.length = 0;
                        for (var i = 0; i < this.mJson.families.length; i++)
                        {
                                var opt = document.createElement('option');
                                opt.value = this.mJson.families[i].id;
                                var name = this.mJson.families[i].name + ' Family';
                                opt.innerHTML = name;
                                select.appendChild(opt);
                        }
                        this.mFamiliesExist = select.length;

			if (this.mApplication.mFamilyId)
			{
				this.getFamilySelect().value = this.mApplication.mFamilyId;
			}
			else
			{
				if (this.mJson.families[0].id)
				{	
					this.getFamilySelect().value = this.mJson.families[0].id;
					this.mApplication.mFamilyId = this.mJson.families[0].id;
				}
			}

			this.getPersons();
                }
        }

//you need to set person after processing persons to set whoever was chosen on choose screeen
	processPersons()
        {
                if (this.mJson.persons)
                {

                        //load up persons option
			this.mApplication.mPersonArray.length = 0;			

		
			//this.mApplication.setPersonId(this.mJson.persons[0].id);
			
			for (var i = 0; i < this.mJson.persons.length; i++)
                        {
                        	var textArray = new Array();
				console.log('this.mJson.persons[i].id:' + this.mJson.persons[i].id);
                                var item = new ChoosePersonItem(this.mApplication, this.mJson.persons[i], this.mJson.persons[i].first_name, textArray, this.mJson.persons[i].id);
                                this.mItemArray.push(item);
                       	}

                        for (var i = 0; i < this.mItemArray.length; i++)
                        {
                                this.mItemArray[i].printToScreen();
                        }
		}
	}
}
