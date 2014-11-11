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
	public $likes;
	public $dislikes;
	
	public $userName;
	public $userId;
	
	public $isSubtitled;
	
	public $thumbnail;
	public $duration;
	
	public $tags;
	public $descriptors;
	public $related;
	public $media;
	
	public $type;
	public $situation;
	public $competence;
	public $lingaspects;
	
	//score an idIndex are used in SearchModule, see ExerciseVO.as for more information
	public $score;
	public $idIndex;
	
	public $itemSelected;
	
	public $_explicitType = "ExerciseVO";

}

?>