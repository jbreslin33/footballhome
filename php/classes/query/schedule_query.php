<?php 
include_once(getenv("DOCUMENT_ROOT") . "/php/classes/query/query.php");

class ScheduleQuery extends Query
{
	function __construct() 
	{
		parent::__construct();
	}

	public function query()
	{
		$this->mQuery = "
		select event_types.name, event_date, start_time, events.address from events join teams on teams.id=events.team_id join teams_users on teams_users.team_id=teams.id join users on users.id=teams_users.user_id join event_types on event_types.id=events.event_types_id where users.username = '" .
		$this->mUsername .
		"' order by event_date asc";
		error_log($this->mQuery);
	}
}

$scheduleQuery = new ScheduleQuery();

?>
