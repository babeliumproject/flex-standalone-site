<?php

class ExerciseVO {
	
	public $id;
	public $exercisecode;
	public $title;
	public $description;
	public $language;
	public $difficulty;
	public $timecreated;
	public $timemodified;
	public $status;
	
	public $userName;
	public $userId;
	
	public $avgRating;
	public $ratingCount;
	
	public $isSubtitled;
	
	public $tags;
	public $descriptors;
	public $related;
	public $media;
	
	//score an idIndex are used in SearchModule, see ExerciseVO.as for more information
	public $score;
	public $idIndex;
	
	public $itemSelected;
	
	public $_explicitType = "ExerciseVO";

}

?>