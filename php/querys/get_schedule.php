<?php
session_start();

include_once(getenv("DOCUMENT_ROOT") . "/php/classes/database/database.php");

$query = "
select event_date, start_time, practices.address from practices join teams on teams.id=practices.team_id join teams_users on teams_users.team_id=teams.id join users on users.id=teams_users.user_id where users.username = 'j' order by event_date asc
";
$database = new Database();

$results = $database->query($query);

$myarray = array();

$resultArray = pg_fetch_all($results);

while ($row = pg_fetch_row($results)) 
{
	$myarray[] = $row;
}
$data = json_encode($myarray);
error_log($data);
echo $data;

?>
