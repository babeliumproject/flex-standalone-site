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
			addCommand(CreateEvent.SAVE_EXERCISE, SaveCreation);
			addCommand(CreateEvent.LIST_CREATIONS, GetCreations);
		}
	}
}