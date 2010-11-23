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
	com.bit101.components.InputText;
	com.bit101.components.PushButton;
	com.bit101.components.ProgressBar;
	com.bit101.components.Window;
	jp.psyark.psycode.core.TextEditUI;
	jp.psyark.utils.StringComparator;
	net.hires.debug.Stats;
	Base64Encoder;

    [SWF(width=950,height=600,scaleMode="noScale",stageAlign="TL",backgroundColor=0xFFFFFF,frameRate=60)]
    public class Nomacs extends Sprite {
        [Embed(source="main.lsr", mimeType="application/octet-stream")]
        protected const Las3rCode:Class;
        protected var las3rCode:String

        public var out:Function;
        public var err:Function;
        public var rt:RT;

		private function outWrapper(s:String):void {out(s);};
		private function errWrapper(s:String):void {err(s);};

		private static var _instance:Nomacs;
		private var spinner:Spinner;

        public function Nomacs() {
			addEventListener(Event.ADDED_TO_STAGE, init);
			if(null != stage) init();
		}

		private function init(event: Event = null): void {
			removeEventListener(Event.ADDED_TO_STAGE, init)
			_instance = this;

			addChild(spinner = new Spinner);
			spinner.x = stage.stageWidth/2;
			spinner.y = stage.stageHeight/2;

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
			rt.evalStr(las3rCode, editorLoaded, spinner.spin, trace);
        }

		private function editorLoaded(val:*):void {
			stage.removeChild(spinner);
			graphics.clear();
		}
    }
}
