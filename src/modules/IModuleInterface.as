package modules
{
	import flash.events.IEventDispatcher;
	
	public interface IModuleInterface extends IEventDispatcher
	{
		function getModuleName():String;
		
		function setDataBindings(data:* = null):void;
		
		function resetModule():void;
	}
}