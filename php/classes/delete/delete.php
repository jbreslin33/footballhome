<?php 
include_once(getenv("DOCUMENT_ROOT") . "/php/classes/database/database.php");

class Delete 
{
	function __construct() 
	{
		$this->mSuccess = false;
		$this->mID = null;
		$this->mSQL = null;
		$this->mData = null;
	}

	public function setSQL($sql)
	{
		$this->mSQL = $sql;
	}
	
	public function getSQL()
	{
		return $this->mSQL;
	}

	public function getData()
	{
		return $this->mData;
	}

	public function getID()
	{
		return $this->mID;
	}
	
	public function getSuccess()
	{
		return $this->mSuccess;
	}

	public function run()
	{
		$database = new Database("localhost","cms","postgres","mibesfat");

                $results = $database->query($this->mSQL);

		if ($results)
		{
			$this->mSuccess = true;
				
			$myarray = array();

                	while ($row = pg_fetch_row($results))
                	{
                        	$myarray[] = $row;
				$this->mID = $row[0];
                	}
                	$this->mData = json_encode($myarray);
		}
		else //we have a problem
		{
			$this->mSuccess = false;
		}

  		$text = "Id deleted: ";
               	$text .= $this->mID;
               	error_log($text);

		return $this->mID;
	}
}
?>