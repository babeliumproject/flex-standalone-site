package commands.main
{
	import business.PreferencesDelegate;

	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;

	import flash.utils.Dictionary;

	import model.DataModel;

	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;

	import view.common.CustomAlert;

	import vo.PreferenceVO;

	public class GetAppPreferencesCommand implements ICommand, IResponder
	{

		private var dataModel:DataModel=DataModel.getInstance();

		public function execute(event:CairngormEvent):void
		{
			new PreferencesDelegate(this).getAppPreferences();
		}

		public function result(data:Object):void
		{

			var result:Object=data.result;
			if (result is Array)
			{
				result=new ArrayCollection(ArrayUtil.toArray(result));

				var dic:Dictionary=new Dictionary();
				for each (var p:PreferenceVO in result)
				{
					dic[p.prefName]=p.prefValue;
				}
				dataModel.prefDic=dic;
				initializePaths();
				initializeFileBounds();
				dataModel.preferencesRetrieved=!dataModel.preferencesRetrieved;
			}

		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources', 'ERROR_WHILE_RETRIEVING_PREFERENCES'));
			trace(ObjectUtil.toString(info));
		}

		private function initializePaths():void
		{
			var server:String=dataModel.prefDic['web_domain'];
			if (server && server.length > 0)
			{
				dataModel.server=server;
				dataModel.uploadDomain="http://" + server + "/";
				dataModel.streamingResourcesPath="rtmp://" + server + "/" + dataModel.streamingApp;
				//dataModel.uploadURL="http://" + server + "/upload.php";
				//dataModel.thumbURL="http://" + server + "/resources/images/thumbs";
				dataModel.uploadURL="/upload.php";
				dataModel.thumbURL="/resources/images/thumbs";
			}
		}
		
		private function initializeFileBounds():void{
			
			if(dataModel.prefDic['minExerciseDuration'] && dataModel.prefDic['minExerciseDuration'].length > 0)
				dataModel.minExerciseDuration = dataModel.prefDic['minExerciseDuration']; //seconds
			if(dataModel.prefDic['maxExerciseDuration'] && dataModel.prefDic['maxExerciseDuration'].length > 0)
				dataModel.maxExerciseDuration = dataModel.prefDic['maxExerciseDuration']; //seconds
			if(dataModel.prefDic['minVideoEvalDuration'] && dataModel.prefDic['minVideoEvalDuration'].length > 0)
				dataModel.minVideoEvalDuration = dataModel.prefDic['minVideoEvalDuration']; //seconds
			if(dataModel.prefDic['maxFileSize'] && dataModel.prefDic['maxFileSize'].length > 0)
				dataModel.maxFileSize = dataModel.prefDic['maxFileSize']; //Bytes (180MB)
		}

	}
}