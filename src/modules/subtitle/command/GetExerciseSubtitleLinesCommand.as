package modules.subtitle.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.subtitle.event.SubtitleEvent;
	import modules.subtitle.service.SubtitleDelegate;
	
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

		private var _model:DataModel=DataModel.getInstance();
		private var _subtitleRoles:ArrayCollection;

		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).getSubtitleLines((event as SubtitleEvent).params);
		}

		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;

			var untouchedSubtitles:ArrayCollection=new ArrayCollection();

			resultCollection=new ArrayCollection(ArrayUtil.toArray(result));
			if (resultCollection.length > 0)
			{
				_subtitleRoles = new ArrayCollection();
				for (var i:int=0; i<resultCollection.length; i++){
					
					generateRoleArray(resultCollection.getItemAt(i));
				}
				untouchedSubtitles=resultCollection;
			}
			
			_model.availableExerciseRoles=_subtitleRoles;
			_model.availableExerciseRolesRetrieved=!_model.availableExerciseRolesRetrieved;
			
			_model.unmodifiedAvailableSubtitleLines=untouchedSubtitles;
			_model.availableSubtitleLines=resultCollection;
			_model.availableSubtitleLinesRetrieved=!_model.availableSubtitleLinesRetrieved;
		}

		private function generateRoleArray(subtitleLine:Object):void
		{
			var containsElement:Boolean = false;
			var tempRole:ExerciseRoleVO=new ExerciseRoleVO(subtitleLine.exerciseRoleId, 0, subtitleLine.exerciseRoleName);
			
			for each(var roleItem:ExerciseRoleVO in _subtitleRoles){
				if(roleItem.id == tempRole.id){
					containsElement=true;
					break;
				}
			}
			if (!containsElement)
			{
				_subtitleRoles.addItem(tempRole);
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_SUBLINES'));
			trace(ObjectUtil.toString(info));
		}

	}
}