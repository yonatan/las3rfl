package {
    import flash.display.Sprite;
    import flash.net.LocalConnection;
    import flash.text.TextField;
	import com.las3r.io.OutputStream;
	import com.las3r.io.InputStream;
	import com.las3r.runtime.RT;

    public class EvalSWF extends Sprite {
		public static var rt:RT;
        private var conn:LocalConnection;
        private var output:TextField;
		private var parameters:Object;
		private var connName:String;
        
        public function EvalSWF() {
			parameters = root.loaderInfo.parameters;
			connName = "connection-" + (parameters.connToken || "");
			
            buildUI();
            
            conn = new LocalConnection();
            conn.client = this;
            try {
                conn.connect(connName);
            } catch (error:ArgumentError) {
                trace("Can't connect...the connection name is already being used by another SWF");
            }
        }
        
        public function eval(code:String):void {
            output.appendText("eval: " + code + "\n");
			conn.send(connName, "printToStdout", "Echo to stdout: " + code + "\n");
			conn.send(connName, "printToStderr", "Echo to stderr: " + code + "\n");
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
	