package modules.create.command
{
	import com.adobe.cairngorm.control.FrontController;
	
	import modules.create.event.CreateEvent;
	
	public class CreateController extends FrontController
	{
		public function CreateController()
		{
			super();
			
			addCommand(CreateEvent.ADD_EXERCISE, AddCreation);
			addCommand(CreateEvent.EDIT_EXERCISE, EditCreation);
			addCommand(CreateEvent.LIST_LATEST_CREATIONS, GetLatestCreations);
			addCommand(CreateEvent.SET_EXERCISE_DATA, SaveCreation);
			addCommand(CreateEvent.SAVE_EXERCISE_MEDIA, SaveExerciseMedia);
			addCommand(CreateEvent.LIST_CREATIONS, GetCreations);
			addCommand(CreateEvent.GET_EXERCISE_MEDIA, GetCreationMedia);
			addCommand(CreateEvent.SET_DEFAULT_THUMBNAIL, SetDefaultThumbnail);
			addCommand(CreateEvent.DELETE_MEDIA, DeleteExerciseMedia);
			addCommand(CreateEvent.GET_EXERCISE_PREVIEW, GetExercisePreview);
			addCommand(CreateEvent.PUBLISH_EXERCISE, PublishExercise);
		}
	}
}