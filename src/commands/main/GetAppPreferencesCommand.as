package commands.main
{
	import business.PreferencesDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.utils.Dictionary;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.PreferenceVO;

	public class GetAppPreferencesCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
				new PreferencesDelegate(this).getAppPreferences();
		}
		
		public function result(data:Object):void
		{
			
			var result:Object = data.result;
			if (result is Array){
				result = new ArrayCollection(ArrayUtil.toArray(result));
				
				var dic:Dictionary = new Dictionary();
				for each( var p:PreferenceVO in result ) {
					dic[p.prefName] = p.prefValue;
				}
				DataModel.getInstance().prefDic = dic;
				DataModel.getInstance().preferencesRetrieved = !DataModel.getInstance().preferencesRetrieved;
			}
			
		}
		
		public function fault(info:Object):void
		{
			var faultEvent : FaultEvent = FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_PREFERENCES'));
			trace(ObjectUtil.toString(info));
		}
		
	}
}