package control
{
	import flash.events.Event;
	
	public class URLChangeEvent extends Event
	{
		
		public static const CHANGE:String = "change";
		
		public var module:String;
		public var action:String;
		public var parameters:Object;
		
		public function URLChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, module:String = null, action:String = null, parameters:Object = null)
		{
			super(type, bubbles, cancelable);
			this.module = module;
			this.action = action;
			this.parameters = parameters;
		}
		
		/**
		 *  @private
		 */
		override public function clone():Event
		{
			return new URLChangeEvent(type, bubbles, cancelable, module, action, parameters);
		}
	}
}