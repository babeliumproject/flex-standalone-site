package commands.main
{
	import business.PreferencesDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.utils.Dictionary;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
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
			}
			
		}
		
		public function fault(info:Object):void
		{
			var faultEvent : FaultEvent = FaultEvent(info);
			Alert.show("Error:"+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}