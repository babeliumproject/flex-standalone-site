package commands.subtitles
{
	import business.SubtitleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.CuePointManager;
	
	import events.SubtitleEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.CueObject;
	import vo.SubtitleLineVO;

	public class GetExerciseSubtitleLinesCommand implements ICommand, IResponder
	{
		private var cueManager:CuePointManager=CuePointManager.getInstance();

		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).getSubtitleLines((event as SubtitleEvent).subtitle);
		}

		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;
			
			var untouchedSubtitles:ArrayCollection = new ArrayCollection();

			if (result is Array)
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));

				if (resultCollection.length > 0)
				{
					if (resultCollection[0] is SubtitleLineVO)
					{
						cueManager.removeAllCue();
						for (var i:int=0; i < resultCollection.length; i++)
						{
							var item:SubtitleLineVO = resultCollection.getItemAt(i) as SubtitleLineVO;
							untouchedSubtitles.addItem(new CueObject(item.showTime,item.hideTime,item.text,item.exerciseRoleId,item.exerciseRoleName));
							cueManager.addCueFromSubtitleLine(item);
						}
					}
				}
				DataModel.getInstance().unmodifiedAvailableSubtitleLines = untouchedSubtitles;
				DataModel.getInstance().availableSubtitleLinesRetrieved=true;
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error("Error while retrieving this exercise's subtitle lines.");
			trace(ObjectUtil.toString(info));
		}

	}
}