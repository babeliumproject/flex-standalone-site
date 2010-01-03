package commands.userManagement
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;

	public class ViewRegisterModuleCommand implements ICommand
	{
		public function ViewRegisterModuleCommand()
		{
		}

		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().viewContentViewStackIndex = 3;
			DataModel.getInstance().registrationErrorMessage = "";
		}
		
	}
}