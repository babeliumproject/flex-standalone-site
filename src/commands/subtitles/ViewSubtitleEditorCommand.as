package commands.subtitles
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.BabeliaBrowserManager;
	
	import events.ViewChangeEvent;
	
	import model.DataModel;
	
	import vo.ExerciseVO;
	
	public class ViewSubtitleEditorCommand implements ICommand
	{
		
		public function execute(event:CairngormEvent):void
		{
			var index:int = ViewChangeEvent.VIEWSTACK_SUBTITLE_MODULE_INDEX;
			DataModel.getInstance().currentSubtitleViewStackIndex = 2;
			
			var tmp:ExerciseVO=DataModel.getInstance().currentExercise.getItemAt(DataModel.SUBTITLE_MODULE) as ExerciseVO;
			
			if (tmp != null)
			{
				BabeliaBrowserManager.getInstance().updateURL(BabeliaBrowserManager.index2fragment(index), // module
					BabeliaBrowserManager.VIEW, // action
					tmp.name); // target
			}
			else
			{
				BabeliaBrowserManager.getInstance().updateURL(BabeliaBrowserManager.index2fragment(index), // module
					BabeliaBrowserManager.VIEW); // action
			}
		}
	}
}