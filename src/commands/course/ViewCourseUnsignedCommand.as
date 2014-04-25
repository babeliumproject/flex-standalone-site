package commands.course
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	public class ViewCourseUnsignedCommand implements ICommand
	{
		public function ViewCourseUnsignedCommand()
		{
		}
		
		public function execute(event:CairngormEvent):void
		{
			DataModel.getInstance().currentCourseViewStackIndex = 0;
		}
	}
}