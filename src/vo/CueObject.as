package vo
{
	import com.adobe.cairngorm.commands.ICommand;
	
	public class CueObject
	{
		private var startTime:Number;
		private var endTime:Number;
		private var role:String;
		private var text:String;
		private var startCommand:ICommand;
		private var endCommand:ICommand;


		public function CueObject(startTime:Number, endTime:Number = -1, text:String = null,
				role:String = null, startCommand:ICommand = null, endCommand:ICommand = null)
		{
			this.startTime = startTime;
			this.endTime = endTime;
			this.text = text;
			this.role = role;
			this.startCommand = startCommand;
			this.endCommand = endCommand;
		}
		
		public function executeStartCommand() : void
		{
			startCommand.execute(null);
		}
		
		public function executeEndCommand() : void
		{
			endCommand.execute(null);
		}
		
		/*
		 * GETTERS & SETTERS
		 */
		public function getStartTime() : Number
		{
			return this.startTime;
		}
		
		public function getEndTime() : Number
		{
			return this.endTime;
		}
		
		public function getText() : String
		{
			return this.text;
		}
		
		public function getRole() : String
		{
			return this.role;
		}
		
		public function setStartTime(time:Number) : void
		{
			this.startTime = time;
		}
		
		public function setEndTime(time:Number) : void
		{
			this.endTime = time;
		}
		
		public function setText(text:String) : void
		{
			this.text = text;
		}
		
		public function setRole(role:String) : void
		{
			this.role = role;
		}
		
		public function setStartCommand(command:ICommand) : void
		{
			this.startCommand = command;
		}
		
		public function setEndCommand(command:ICommand) : void
		{
			this.endCommand = command;
		}

	}
}