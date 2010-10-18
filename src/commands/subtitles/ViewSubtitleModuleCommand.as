package commands.subtitles
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.BabeliaBrowserManager;
	
	import events.CloseConnectionEvent;
	import events.ViewChangeEvent;
	
	import model.DataModel;
	
	import modules.subtitles.SubtitleMain;
	
	import vo.ExerciseVO;

	public class ViewSubtitleModuleCommand implements ICommand
	{

		public function execute(event:CairngormEvent):void
		{
			var index:Class=ViewChangeEvent.VIEWSTACK_SUBTITLE_MODULE_INDEX;
			new CloseConnectionEvent().dispatch();
			if(DataModel.getInstance().appBody.getChildren().length > 0)
				DataModel.getInstance().appBody.removeAllChildren();
			DataModel.getInstance().appBody.addChild(new index());
			
			if(DataModel.getInstance().isLoggedIn)
				DataModel.getInstance().currentSubtitleViewStackIndex = 1;
			else
				DataModel.getInstance().currentSubtitleViewStackIndex = 0;
			
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