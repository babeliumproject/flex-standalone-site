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
			addCommand(CreateEvent.GET_LATEST_CREATIONS, GetLatestCreations);
			addCommand(CreateEvent.MODIFY_VIDEO_DATA, ModifyVideoDataCommand);
			addCommand(CreateEvent.RETRIEVE_USER_VIDEOS, RetrieveUserVideosCommand);
		}
	}
}