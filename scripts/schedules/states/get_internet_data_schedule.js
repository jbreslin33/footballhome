
'use strict';

class GET_INTERNET_DATA_SCHEDULE extends State
{
	constructor() 
	{
		super();
	}
        
	enter(schedule)
        {
		if (schedule.mStateLogs || schedule.mStateEnterLogs)
		{
			console.log("GET_INTERNET_DATA_SCHEDULE: ENTER");        
		}
		//delete previous data

		for (var i=0; i < schedule.mSelectEventoArray.length; i++)
		{
			schedule.mSelectEventoArray[i].destructor();
			schedule.mSelectEventoArray[i] = null;
			delete schedule.mSelectEventoArray[i];
		}
		//get new data from internets
		schedule.getSchedule();
	}

        execute(schedule)
        {
		if (schedule.mStateLogs || schedule.mStateExecuteLogs)
		{
			console.log("GET_INTERNET_DATA_SCHEDULE: EXECUTE");        
		}
		//do we have something to display???
		if (schedule.mSelectEventoArray.length > 0)
		{
 			schedule.mStateMachine.changeState(schedule.mDISPLAY_SCHEDULE);
		}
	}

        exit(schedule)
        {
		if (schedule.mStateLogs || schedule.mStateExitLogs)
		{
			console.log("GET_INTERNET_DATA_SCHEDULE: EXIT");        
		}
	}
}
