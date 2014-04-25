package commands.course
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	public class ViewCourseSignedCommand implements ICommand
	{
		public function ViewCourseSignedCommand()
		{
		}
		
		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().currentCourseViewStackIndex = 1;
		}
	}
}