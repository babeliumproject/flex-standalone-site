package commands.course
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.BabeliaBrowserManager;
	
	import events.ViewChangeEvent;
	
	import model.DataModel;
	
	public class ViewCourseModuleCommand implements ICommand
	{
		public function ViewCourseModuleCommand()
		{
		}
		
		public function execute(event:CairngormEvent):void
		{
			var index:uint = ViewChangeEvent.VIEWSTACK_COURSE_MODULE_INDEX;
			DataModel.getInstance().currentContentViewStackIndex = index;
			
			BabeliaBrowserManager.getInstance().updateURL(BabeliaBrowserManager.index2fragment(index));
		}
	}
}