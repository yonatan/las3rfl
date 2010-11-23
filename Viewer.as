package {
    import flash.display.*;
    import flash.net.*;
    import flash.events.*;
	import com.las3r.io.OutputStream;
	import com.las3r.io.InputStream;
	import com.las3r.runtime.RT;

	[SWF(width="465", height="465")]
    public class Viewer extends Sprite {
		public static var rt:RT;
		private var parameters:Object;
		private var spinner:Spinner;
		private var ldr:URLLoader;
        
        public function Viewer() {
			addEventListener(Event.ADDED_TO_STAGE, init);
			if(null != stage) init();
		}

		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = "noScale";
			stage.align = "TL";
			addChild(spinner = new Spinner);
			spinner.x = stage.stageWidth/2;
			spinner.y = stage.stageHeight/2;

			parameters = root.loaderInfo.parameters;
			
			if(null == parameters.nid) {
				throw(new Error("No nid parameter"));
			}

			// setup las3r
			rt = new RT(stage, new OutputStream(trace), new OutputStream(trace));
			rt.loadStdLib(stdlibLoaded);
        }

		private function stdlibLoaded(val:*):void {
			ldr = new URLLoader;
			ldr.addEventListener("complete", codeLoaded);
			ldr.addEventListener("progress", spinner.spin);
			ldr.load(new URLRequest("/node/" + parameters.nid + "/raw"));
		}

		private function codeLoaded(e:Event):void {
			ldr.removeEventListener("complete", codeLoaded);
			ldr.removeEventListener("progress", spinner.spin);
			addChild(spinner = new Spinner);
			spinner.x = stage.stageWidth/2;
			spinner.y = stage.stageHeight/2;

			var code:String = "" +
			"(in-ns 'user)" +
			"(las3r.core/refer 'las3r.core :exclude '(run-tests))" +
			ldr.data;

			rt.evalStr(code, evalDone, spinner.spin, trace);
        }

		private function evalDone(x:*):void {
			removeChild(spinner);
		}
    }
}