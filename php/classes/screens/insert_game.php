<?php 
include_once(getenv("DOCUMENT_ROOT") . "/php/classes/screens/screen.php");

class InsertGame extends Screen
{
	function __construct() 
	{
		parent::__construct();
	}

	function getResult()
	{
		$event_date = null;
		$arrival_time = null;
		$start_time = null;
		$end_time = null;
		$address = null;
		$coordinates = null;
		$field_name = null;
	
		if (isset($_GET['event_date']))
		{
			$event_date = $_GET['event_date'];
		}
		if (isset($_GET['arrival_time']))
		{
			$arrival_time = $_GET['arrival_time'];
		}
		if (isset($_GET['start_time']))
		{
			$start_time = $_GET['start_time'];
		}
		if (isset($_GET['end_time']))
		{
			$end_time = $_GET['end_time'];
		}
		if (isset($_GET['address']))
		{
			$address = $_GET['address'];
		}
		if (isset($_GET['coordinates']))
		{
			$coordinates = $_GET['coordinates'];
		}
		if (isset($_GET['field_name']))
		{
			$field_name = $_GET['field_name'];
		}

		if ($event_date)
		{
			//if ($this->getAuthorizationId() > 0)
			//prep db
			$sql = 'select f_insert_game($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)';
			$prepare_result = pg_prepare($this->mDatabase->mConnection, "f_insert_game", $sql);
			$result = pg_execute($this->mDatabase->mConnection, "f_insert_game", array( $this->mFamilyId, $this->mPersonId, $this->mTeamId, $event_date, $arrival_time, $start_time, $end_time, $address, $coordinates, $this->mPitchId, $field_name));
			
			return pg_fetch_result($result, 0);
		}
        }
}

$insertGame = new InsertGame();	

?>
