package cn.daftlib.touch.clients
{
	import flash.display.Stage;
	import flash.events.Event;
	
	import cn.daftlib.touch.interfaces.ITouchListener;
	import cn.daftlib.touch.osc.OSCMessageEvent;
	import cn.daftlib.touch.osc.OSCSocket;
	import cn.daftlib.touch.vo.TuioCursor;
	import cn.daftlib.touch.vo.TuioObject;

	public final class TuioClient
	{
		private var __stage:Stage;
		private var __listerner:ITouchListener;

		private var __host:String;
		private var __port:Number;
		private var __socket:OSCSocket = new OSCSocket();
		private var __frameCount:int;
		private var __cursorArr:Array = [];
		private var __objectArr:Array = [];

		public function TuioClient(listerner:ITouchListener, stage:Stage, host:String, port:Number)
		{
			__listerner = listerner;
			__stage = stage;

			__host = host;
			__port = port;

			startSocket();
		}
		private function startSocket(e:Event = null):void
		{
			try
			{
				__socket.addEventListener(OSCMessageEvent.MESSAGE_RECEIVED, dataHandler);
				__socket.connect(__host, __port);
			}
			catch(e:Error)
			{
				trace(TuioClient, e.message);
			}
		}
		/**
		 * processMessage related
		 * @param byteArray
		 * @return
		 */
		private function processMessage(data:Array):void
		{
			var path:String = data[0];
			var type:String = data[1];
			var i:int;
			//trace(data);
			if(path == "/tuio/2Dcur")
			{
				if(type == "alive")
				{
					for each(var tc:TuioCursor in __cursorArr)
					{
						tc.isAlive = false;
					}

					var curID:int;
					for(i = 2; i < data.length; i++)
					{
						curID = data[i];
						var tc1:TuioCursor = getCursorById(curID);
						if(getCursorById(curID) != null)
						{
							getCursorById(curID).isAlive = true;
						}
					}

					var aliveCurLen:int = __cursorArr.length;

					for(i = 0; i < aliveCurLen; i++)
					{
						var tc2:TuioCursor = __cursorArr[i];

						if(tc2.isAlive == false)
						{
							//$touchListener.removeTuioCursor(tc2);
							__listerner.removeTouchCursor(tc2.sessionID);

							__cursorArr.splice(i, 1);
							i--;
							aliveCurLen = __cursorArr.length;
						}
					}

				}
				else if(type == "set")
				{
					var id:int = data[2], x:Number = data[3], y:Number = data[4], X:Number = data[5], Y:Number = data[6], m:Number = data[7], wd:Number = data[8], ht:Number = data[9];

					var tc3:TuioCursor = getCursorById(id);

					if(tc3 == null)
					{
						tc3 = new TuioCursor("2Dcur", id, x, y, 0, X, Y, 0, m, __frameCount);
						__cursorArr.push(tc3);
						//$touchListener.addTuioCursor(tc3);
						__listerner.addTouchCursor(tc3.sessionID, tc3.x, tc3.y);
					}
					else
					{
						tc3 = new TuioCursor("2Dcur", id, x, y, 0, X, Y, 0, m, __frameCount);
						//$touchListener.updateTuioCursor(tc3);
						__listerner.updateTouchCursor(tc3.sessionID, tc3.x, tc3.y);
					}

				}
				else if(type == "fseq")
				{
					__frameCount = data[2];
				}
			}
			else if(path == "/tuio/2Dobj")
			{
				type = data[1];

				if(type == "set")
				{
					var s_id:Number;
					var f_id:Number;
					var xpos:Number;
					var ypos:Number;
					var angle:Number;
					var xspeed:Number;
					var yspeed:Number;
					var rspeed:Number;
					var maccel:Number;
					var raccel:Number;
					var speed:Number;

					try
					{
						s_id = data[2];
						f_id = data[3];
						xpos = data[4];
						ypos = data[5];
						angle = Number(data[6]);
						xspeed = Number(data[7]);
						yspeed = Number(data[8]);
						rspeed = Number(data[9]);
						maccel = Number(data[10]);
						raccel = Number(data[11]);
						speed = Math.sqrt((xspeed * xspeed) + (yspeed * yspeed));

						var to:TuioObject = getObjectById(s_id);

						if(to == null)
						{
							to = new TuioObject("2Dobj", s_id, f_id, xpos, ypos, 0, angle, 0, 0, xspeed, yspeed, 0, rspeed, 0, 0, maccel, raccel, __frameCount);
							__objectArr.push(to);
							//$touchListener.addTuioObject(to);
							__listerner.addTouchObject(to.classID, to.x, to.y, to.a);
						}
						else
						{
							to = new TuioObject("2Dobj", s_id, f_id, xpos, ypos, 0, angle, 0, 0, xspeed, yspeed, 0, rspeed, 0, 0, maccel, raccel, __frameCount);
							//$touchListener.updateTuioObject(to);
							__listerner.updateTouchObject(to.classID, to.x, to.y, to.a);
						}

					}
					catch(e:Error)
					{
						trace("Error Object parsing");
					}
				}
				else if(type == "alive")
				{
					for each(var to1:TuioObject in __objectArr)
					{
						to1.isAlive = false;
					}

					var sID:Number;
					for(i = 2; i < data.length; i++)
					{
						sID = data[i];
						var to2:TuioObject = getObjectById(sID);
						if(getObjectById(sID) != null)
						{
							getObjectById(sID).isAlive = true;
						}
					}

					var aliveObjLen:int = __objectArr.length;

					for(i = 0; i < aliveObjLen; i++)
					{
						var to3:TuioObject = __objectArr[i];

						if(to3.isAlive == false)
						{
							//$touchListener.removeTuioObject(to3);
							__listerner.removeTouchObject(to3.classID);

							__objectArr.splice(i, 1);
							i--;
							aliveObjLen = __objectArr.length;
						}
					}
				}
			}
		}
		private function getCursorById(id:int):TuioCursor
		{
			for each(var tc:TuioCursor in __cursorArr)
			{
				if(tc.sessionID == id)
				{
					return tc;
				}
			}
			return null;
		}
		private function getObjectById(id:int):TuioObject
		{
			for each(var to:TuioObject in __objectArr)
			{
				if(to.sessionID == id)
				{
					return to;
				}
			}
			return null;
		}
		/**
		 * Socket connect related
		 * @param event
		 */
		private function dataHandler(e:OSCMessageEvent):void
		{
			processMessage(e.data);
		}
	}
}