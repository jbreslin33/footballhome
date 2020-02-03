<?php 
include_once(getenv("DOCUMENT_ROOT") . "/php/classes/screens/screen.php");

class DeleteClub extends Screen 
{
	function __construct() 
	{
		parent::__construct();
	}

	function getResult()
	{
		$club_id = null;

               	if (isset($_GET['club_id']))
                {
                        $club_id = $_GET['club_id'];
                }

		$sql = 'select f_delete_club($1,$2,$3)';
		$prepare_result = pg_prepare($this->mDatabase->mConnection, "f_delete_club", $sql);
		$result = pg_execute($this->mDatabase->mConnection, "f_delete_club", array( $this->getSenderEmailId(), $this->mPersonId, $club_id));

               	return pg_fetch_result($result, 0);
        }
}

$deleteClub = new DeleteClub();	

?>