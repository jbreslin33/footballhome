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
			select affair_date, arrival_time, start_time, end_time, affairs.address, affairs.coordinates, pitches.name, field_name, teams.name, affair_types.name
			from affairs
			full outer join teams on teams.id=affairs.team_id
			full outer join affair_types on affair_types.id=affairs.affair_types_id
			full outer join pitches      on pitches.id=affairs.pitch_id
			where affair_date >= now()
                        and users.username = '" .
                        $this->mUsername .
			"' order by affair_date asc";
	}
}

$scheduleQuery = new ScheduleQuery();

?>
