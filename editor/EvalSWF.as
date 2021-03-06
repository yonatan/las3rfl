package {
    import flash.display.*;
    import flash.events.*;
    import flash.net.LocalConnection;
    import flash.text.TextField;
	import flash.utils.ByteArray;
	import com.las3r.io.OutputStream;
	import com.las3r.io.InputStream;
	import com.las3r.runtime.RT;
	import com.adobe.images.JPGEncoder;

	[SWF(width="465", height="465")]
    public class EvalSWF extends Sprite {
		public static var rt:RT;
        private var recvConn:LocalConnection;
        private var sendConn:LocalConnection;
        private var output:TextField;
		private var parameters:Object;
		private var debug:Boolean;
		private var connToken:String;
        
        public function EvalSWF() {
			addEventListener(Event.ADDED_TO_STAGE, init);
			if(null != stage) init();
		}

		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = "noScale";
			stage.align = "TL";
			parameters = root.loaderInfo.parameters;
			debug = parameters.debug;
			connToken = (parameters.connToken || "");

			if(debug) buildUI();
            
			// setup las3r
			rt = new RT(stage, new OutputStream(stdout), new OutputStream(stderr));
			rt.loadStdLib(stdlibLoaded);
        }

		private function stdlibLoaded(val:*):void {
			rt.evalStr(
				"(in-ns 'user)" +
				"(las3r.core/refer 'las3r.core :exclude '(run-tests))"
			);

			// setup local connections
            recvConn = new LocalConnection();
			if(parameters.siteDomain) {
				if(debug) output.appendText("site domain: " + parameters.siteDomain);
				recvConn.allowDomain(parameters.siteDomain);
			} else {
				if(debug) output.appendText("no site domain");
			}
            sendConn = new LocalConnection();
			recvConn.addEventListener("status", 
				function(e:StatusEvent):void {
					if(e.type != "status" && debug) output.appendText('\nrecv status: ' + e);
				});
			sendConn.addEventListener("status", 
				function(e:StatusEvent):void {
					if(e.type != "status" && debug) output.appendText('\nsend status: ' + e);
				});
            recvConn.client = this;
            try {
                recvConn.connect("_eval-in-" + connToken);
				if(debug) output.text = "Listening on _eval-in-" + connToken;
				stdout("Evaluator ready.\n");
            } catch (error:ArgumentError) {
                trace("Can't connect... _eval-in-" + connToken + " is already being used by another SWF");
            }
        }

		private function stdout(s:String):void {
			sendConn.send("_eval-out-" + connToken, "printToStdout", s || "nil");
		}

		private function stdoutLine(s:String):void {
			stdout(s + "\n");
		}

		private function stderr(s:String):void {
			sendConn.send("_eval-out-" + connToken, "printToStderr", s || "nil");
		}
        
        public function eval(code:String):void {
			rt.evalStr(code, stdoutLine, null, stderr);
            if(debug) output.appendText("eval: " + code + "\n");
        }

		public function capture():void {
			var bmd:BitmapData = new BitmapData(465, 465, false);
			var jpeg:ByteArray;
			var encoder:JPGEncoder;

			bmd.draw(stage);

			// LocalConnection is only good for < 40k
			// try lower quality compression if neccesary
			for(var quality:int = 50; quality > 4; quality /= 2) {
				encoder = new JPGEncoder(quality);
				jpeg = encoder.encode(bmd);
				if(jpeg.length < 40000) break; 
			}
			
			if(quality > 4) {
				if(debug) {
					output.appendText("jpeg quality: " + quality + "\n");
					output.appendText("jpeg size: " + jpeg.length + "\n");
				}
				sendConn.send("_eval-out-" + connToken, "updateCapture", jpeg);
			}
		}

        private function buildUI():void {
            output = new TextField();
            output.background = true;
            output.border = true;
            output.wordWrap = true;
			output.width = stage.stageWidth;
			output.height = stage.stageHeight;
            addChild(output);
        }
    }
}