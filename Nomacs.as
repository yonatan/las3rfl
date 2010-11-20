// forked from psyark's F-siteで紹介したエディタを無理やりWonderflに突っ込んでみた
package {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;
    import flash.utils.*;
	import com.las3r.io.OutputStream;
	import com.las3r.runtime.RT;
	import com.bit101.components.*;
	import jp.psyark.psycode.core.TextEditUI;
	import jp.psyark.utils.StringComparator;
	import net.hires.debug.Stats;

	// classes used by las3r code
	com.bit101.components.TextArea;
	com.bit101.components.Text;
	com.bit101.components.PushButton;
	com.bit101.components.ProgressBar;
	com.bit101.components.Window;
	jp.psyark.psycode.core.TextEditUI;
	jp.psyark.utils.StringComparator;
	net.hires.debug.Stats;

    [SWF(width=950,height=600,backgroundColor=0xFFFFFF,frameRate=60)]
    public class Nomacs extends Sprite {
        [Embed(source="main.lsr", mimeType="application/octet-stream")]
        protected const Las3rCode:Class;
        protected var las3rCode:String

        public var out:Function;
        public var err:Function;
        public var rt:RT;

		private var progressCounter:int = 0;

		private function outWrapper(s:String):void {out(s);};
		private function errWrapper(s:String):void {err(s);};

		public var connToken:String;
		private var parameters:Object;
		private static var _instance:Nomacs;

        public function Nomacs() {
			_instance = this;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

			// setup local connections
			parameters = root.loaderInfo.parameters;
			connToken = (parameters.connToken || "");

			// setup las3r
			out = err = trace;
            las3rCode = ByteArray(new Las3rCode).toString();

			rt = new RT(stage, new OutputStream(outWrapper), new OutputStream(errWrapper));
			rt.loadStdLib(stdlibLoaded, trace, trace);
		}

		public static function get instance():Nomacs {
			return _instance;
		}

		private function stdlibLoaded(val:*):void {
			rt.evalStr(las3rCode, editorLoaded, progress, trace);
        }

		private static const LINES:uint = 24;
		private function progress():void {
			var cx:Number = stage.stageWidth / 2;
			var cy:Number = stage.stageHeight / 2;
			progressCounter++;

			graphics.clear();

			for(var i:uint = 0; i < LINES; i++) {
				var z:Number = (i+progressCounter) / LINES * (Math.PI * 2);
				var sz:Number = Math.sin(z);
				var cz:Number = Math.cos(z);
				var c:uint = i / LINES * 0xff;
				c = 0xff ^ c;
				c = c << 16 | c << 8 | c;
				graphics.lineStyle(3, c);
				graphics.moveTo(cx - sz * 25, cy + cz * 25);
				graphics.lineTo(cx - sz * 40, cy + cz * 40);
			}
		}

		private function editorLoaded(val:*):void {
			graphics.clear();
		}
    }
}
