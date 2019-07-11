<?php 
include_once(getenv("DOCUMENT_ROOT") . "/php/classes/database/database.php");
include_once(getenv("DOCUMENT_ROOT") . "/php/classes/jwt/jwt.php");
include_once(getenv("DOCUMENT_ROOT") . "/php/classes/onering/onering.php");

class InsertClub 
{
	function __construct() 
	{
                $database = new Database("localhost","cms","postgres","mibesfat");

		//actually we are going to get the jwt and need to extract id

		$sql = 'select f_insert_club($1,$2,$3,$4)';
		
		$prepare_result = pg_prepare($database->mConnection, "f_insert_club", $sql);

		$jwt = $_GET['jwt'];
		$oneRing = new OneRing();
                $payload = JWT::decode($jwt, $oneRing->mOneRing);
		$email_id = $payload->email_id;

		$result = pg_execute($database->mConnection, "f_insert_club", array( $_GET['name'] ,$_GET['address'], $email_id, $_GET['person_id']));

               	$return_value = pg_fetch_result($result, 0);

		$result_set = $database->formatResultSet($return_value);
                echo $result_set;
        }
}

$insertClub = new InsertClub();	

?>
