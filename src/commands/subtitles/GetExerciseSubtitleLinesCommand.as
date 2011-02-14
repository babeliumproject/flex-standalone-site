package commands.subtitles
{
	import business.SubtitleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import control.CuePointManager;
	
	import events.SubtitleEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.CueObject;
	import vo.ExerciseRoleVO;
	import vo.SubtitleLineVO;

	public class GetExerciseSubtitleLinesCommand implements ICommand, IResponder
	{
		private var cueManager:CuePointManager=CuePointManager.getInstance();

		private var subtitleRoles:ArrayCollection=new ArrayCollection();

		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).getSubtitleLines((event as SubtitleEvent).subtitle);
		}

		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;

			var untouchedSubtitles:ArrayCollection=new ArrayCollection();

			if (result is Array)
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));

				if (resultCollection.length > 0)
				{
					if (resultCollection[0] is SubtitleLineVO)
					{
						for (var i:int=0; i < resultCollection.length; i++)
						{
							var item:SubtitleLineVO=resultCollection.getItemAt(i) as SubtitleLineVO;
							generateRoleArray(item);
							untouchedSubtitles.addItem(new CueObject(item.subtitleId, item.showTime, item.hideTime, item.text, item.exerciseRoleId, item.exerciseRoleName));
							cueManager.addCueFromSubtitleLine(item);
						}
					}
				}
				//Exercise Role bindings
				DataModel.getInstance().availableExerciseRoles.setItemAt(subtitleRoles, DataModel.SUBTITLE_MODULE);
				DataModel.getInstance().availableExerciseRoles.setItemAt(subtitleRoles, DataModel.RECORDING_MODULE);
				DataModel.getInstance().availableExerciseRolesRetrieved = new ArrayCollection(new Array (true, true));
				
				
				//Subtitle editor bindings
				DataModel.getInstance().unmodifiedAvailableSubtitleLines=untouchedSubtitles;
				DataModel.getInstance().availableSubtitleLinesRetrieved=true;
			}
		}

		private function generateRoleArray(subtitleLine:SubtitleLineVO):void
		{
			var containsElement:Boolean = false;
			var tempRole:ExerciseRoleVO=new ExerciseRoleVO(subtitleLine.exerciseRoleId, 0, subtitleLine.exerciseRoleName);
			
			for each(var roleItem:ExerciseRoleVO in subtitleRoles){
				if(roleItem.id == tempRole.id){
					containsElement=true;
					break;
				}
			}
			if (!containsElement)
			{
				subtitleRoles.addItem(tempRole);
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_SUBTITLE_LINES'));
			trace(ObjectUtil.toString(info));
		}

	}
}