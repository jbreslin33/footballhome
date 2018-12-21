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
		select affair_date, arrival_time, start_time, end_time, affairs.address, affairs.coordinates, pitch_id, field_name, affairs.team_id, affair_types.name from affairs join teams on teams.id=affairs.team_id join teams_users on teams_users.team_id=teams.id join users on users.id=teams_users.user_id join affair_types on affair_types.id=affairs.affair_types_id where users.username = '" .
		$this->mUsername .
		"' order by affair_date asc";
		error_log($this->mQuery);
	}
}

$scheduleQuery = new ScheduleQuery();

?>
