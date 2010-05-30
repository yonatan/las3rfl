// forked from psyark's F-siteで紹介したエディタを無理やりWonderflに突っ込んでみた
package {
    import flash.display.*;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.net.*;
    import flash.system.*;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    import flash.utils.*;
    import net.hires.debug.Stats;
    
    [SWF(width=465,height=465,backgroundColor=0xFFFFFF,frameRate=60)]
    public class Psymacs extends Sprite {
        public static var instance:Psymacs;
        public var keyDownHook:Function;
        public var las3rHighlightHook:Function;
        public var tabView:TabView;
        public var miniBuffer:MiniBuffer;
        public var stats:Stats = new Stats;
        public var rt:*;
        
        public function Psymacs() {
            instance = this;
            loadLas3rSwf(init);
        }

        private function loadLas3rSwf(completeHandler:Function):void {
            Security.loadPolicyFile("http://zozuar.org/wonderfl/crossdomain.xml");
            var loader:Loader;
            var req:URLRequest = new URLRequest("http://zozuar.org/wonderfl/las3r.swf");
            var ctx:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.load(req, ctx);
        }

        private function init(e:Event):void {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            tabView = new TabView();
            addChild(tabView);
            
            //tabView.addItem(new TextEditor(), "無題");
            tabView.addEventListener(Event.OPEN, function (event:Event):void {
                    tabView.addItem(new TextEditor(), "無題");
                });

            miniBuffer = new MiniBuffer();
            addChild(miniBuffer);
            
            stage.addEventListener(Event.RESIZE, updateLayout);
            stage.addEventListener(Event.ENTER_FRAME, updateLayout);
            addChild(stats);
			stats.visible = false;
            updateLayout();

            initRuntime();
        }

        private function initRuntime():void {
            var RT:Class = getDefinitionByName("com.las3r.runtime.RT") as Class;
            var OutputStream:Class = getDefinitionByName("com.las3r.io.OutputStream") as Class;

            var stdout:* = new OutputStream(function(str:String):void {miniBuffer.textField.appendText(str);});
            
            rt = new RT(stage, stdout, stdout);

            try {
                rt.loadStdLib(
                    function(val:*):void { 
                        miniBuffer.text = "Las3r runtime loaded.\n"; 
                        rt.evalStr(las3rCode);
                    },
                    function(i:int, total:int):void{ miniBuffer.text += "."; },
                    function(error:*):void{ miniBuffer.text = error; },
                    false/*true=from-source*/
                );
                rt.evalStr("(in-ns 'las3r.core)");
            }
            catch(e:*){
                miniBuffer.text = e;
            }
            
        }

        public function updateLayout(event:Event=null):void {
            tabView.width = miniBuffer.width = stage.stageWidth;
            miniBuffer.height = Math.min(
                miniBuffer.textField.textHeight + ScrollBar.BAR_THICKNESS * 3, 
                stage.stageHeight / 4);
            miniBuffer.y = tabView.height = stage.stageHeight - miniBuffer.height;
            stats.x = stage.stageWidth - stats.width;
        }

        private var las3rCode:String = <![CDATA[
;; Globals

(defn get-def
  "flash.utils.getDefinitionByName"
  [name]
  (. com.las3r.runtime.RT (objectForName name)))

(def get-timer (get-def "flash.utils.getTimer"))

(def *psymacs* (. (get-def "Psymacs") instance)) ;; editor instance

(def *mini-buffer* (. *psymacs* miniBuffer))
(defn clear-mini-buffer! []
  (set! (. *mini-buffer* text) ""))

;; Utils

(defn current-buffer
  "Return the current buffer as a TextEditor object."
  []
  (let [tv (. *psymacs* tabView)
    idx (. tv selectedIndex)]
    (. tv (getItemAt idx))))

(defn buffer-string
  "Returns the buffer's content as a string (defaults to current-buffer)."
  ([buffer] (. buffer text))
  ([]       (. (current-buffer) text)))

(defn buffer-textfield
  "Returns the buffer's TextField (defaults to current-buffer)."
  ([buffer] (. buffer textField))
  ([]       (. (current-buffer) textField)))

(defn buffers
  "Returns a list of buffers (TextEditor objects)."
  []
  (map (fn [x] (. x content)) (seq (. (. *psymacs* tabView) items))))

(defn point
  "Return value of point, as an integer. Beginning of buffer is position 0."
  []
  (. (buffer-textfield) caretIndex))

(defn char-at
  "Returns the char at a position in a buffer (defaults to current-buffer and point)."
  ([position buffer] (nth (buffer-string buffer) position))
  ([position]        (nth (buffer-string (current-buffer)) position))
  ([]                (nth (buffer-string (current-buffer)) (point))))

;; Shared object (local storage)

(def *psymacs-so* (. flash.net.SharedObject (getLocal "psymacsContent")))

(defn save-to-lso!
  "Save editor content to local storage. Returns the output of flush()."
  []
  (set! (. (. *psymacs-so* data) tabs)
    (to-array (map (fn [tab]
                     (let [tab-obj (new Object)]
                       (set! (. tab-obj title) (. tab title))
                       (set! (. tab-obj text) (. (. (. tab content) textField) text))
                       tab-obj))
                   (seq (. (. *psymacs* tabView) items))))) ; all tabs
  (. *psymacs-so* (flush)))

(defn load-from-lso!
  "Load editor content from local storage."
  []
  (let [tab-view (. *psymacs* tabView)
    saved-tabs (seq (. (. *psymacs-so* data) tabs))]
    (if saved-tabs
      (doseq tab saved-tabs
    (. tab-view (addItemWithText (. tab text) (. tab title)))))))

;; Bracket utils

(defn paren?    [c] (contains? "()"     c))
(defn square?   [c] (contains? "[]"     c))
(defn curly?    [c] (contains? "{}"     c))
(defn bracket?  [c] (contains? "([{}])" c))
(defn lbracket? [c] (contains? "([{"    c))
(defn rbracket? [c] (contains? "}])"    c))

(defn matching-bracket
  "Returns c's matching bracket or nil."
  [c]
  (get {"(" ")", ")" "(", "[" "]", "]" "[", "{" "}", "}" "{"} c))

;; Regex helper

(defn re-matches-ex
  "A bit like re-matches, but not lazy, and returns more info (including the offset of every match). Works by using RegExp.replace with a replacement function and collecting its arguments." 
  [r s]
  (let [ret (new Array)]
    (. s (replace r (fn [& args]
                      (. ret (push (butlast args))))))
    (seq ret)))

;; Parser

(def *qp-last-input* nil)
(def *qp-last-output* nil)

(defn quick-parse
  "Applies a parsing regex to s, caches and returns the result (as a vector of matches)."
  [s]
  (if (= *qp-last-input* s)
    *qp-last-output*
    (let [ret (vec (re-matches-ex #"#(\"(?:\\?+.)*?\")[gismx]*|(\"(?:\\?+.)*?\")|([\(\[\{])|([\)\]\}])|(;[^\r]*)|([^\s\(\[\{\}\]\)\";,]+)|[\r\s,]+"gms s))]
      (def *qp-last-input* s)
      (def *qp-last-output* ret)
      ret)))

;; Parse results search

(defn match-index-for-point
  "Returns the index of the match at position, matches should be the output of re-match-ex, position is the character index."
  [matches position]
  (if (seq matches) ;; bail if no matches
    (loop [lo 0
           hi (dec (count matches))]
      (if (= hi lo)
        lo
        (let [mid (+ lo (bit-shr (- hi lo) 1))]
          (if (< position (last (nth matches mid))) 
            (recur lo (dec mid))
            (if (>= position (last (nth matches (inc mid))))
              (recur (inc mid) hi)
              mid)))))))

;; Bracket matching

(defn find-unmatched-bracket
  "Starts searching right after token-idx, returns the index of the first unmatched bracket."
  [parsed-data token-idx bracket]
  (let [[limit next] (if (lbracket? bracket) 
                       [-1 dec]
                       [(count parsed-data) inc])
        opposite (matching-bracket bracket)]
    (loop [idx (next token-idx)
           nesting 0]
      (if (= idx limit)
        nil
        (cond (= (first (nth parsed-data idx)) bracket)
              (if (zero? nesting)
                idx
                (recur (next idx) (dec nesting)))

              (= (first (nth parsed-data idx)) opposite)
              (recur (next idx) (inc nesting))

              :else (recur (next idx) nesting))))))

(defn matching-bracket-position
  "Returns the position of the bracket matching the one at position, or nil if not found or no bracket at position. String and position default to current buffer string and point."
  ([] (matching-bracket-position (buffer-string) (point)))
  ([string] (matching-bracket-position string (point)))
  ([string position]
    (if (bracket? (char-at))
      (let [matches (quick-parse string)
            match-idx (match-index-for-point matches position)
            match (first (nth matches match-idx))]
        (if (bracket? match)
          (let [idx (find-unmatched-bracket matches match-idx (matching-bracket match))]
            (and idx (last (nth matches idx)))))))))

;; Context doc

(defn minibuff-print-doc 
  "Like print-doc, with different formatting."
  [v]
  (println (str (ns-name (get ^v :ns)) "/" (get ^v :name) 
        (if (get ^v :macro) " - Macro" "")))
  (prn (get ^v :arglists))
  (println " " (get ^v :doc)))

(defn back-search-for-context-doc
  "Returns the first token after the first preceding unmatched lparen."
  []
  (let [matches (quick-parse (buffer-string))
        match-idx (match-index-for-point matches (point))
        lparen-idx (find-unmatched-bracket (quick-parse (buffer-string)) match-idx "(")]
    (first (nth matches (inc lparen-idx)))))

(defn context-doc
  "Shows the enclosing function's documentation in the minibuffer."
  []
  (let [name (back-search-for-context-doc)]
    (if name 
      (try
        (let [v (find-var (symbol (ns-name *ns*) name))
              arglists ((meta v) :arglists)]
          (minibuff-print-doc v))
        (catch Error e nil)))))

(def *print-doc* false)

(defn context-doc-frame-handler [e]
  (if *print-doc*
    (do (def *print-doc* false)
        (clear-mini-buffer!)
        (context-doc))))

;; Syntax highlighter

(def *plain-format*   (new flash.text.TextFormat nil nil 0xa0a0a0 true)) ;; used on whitespace (and commas)
(def *regex-format*   (new flash.text.TextFormat nil nil 0x00aa22 true))
(def *string-format*  (new flash.text.TextFormat nil nil 0xaa8800 true))
(def *comment-format* (new flash.text.TextFormat nil nil 0xcc2200 true))
(def *paren-format*   (new flash.text.TextFormat nil nil 0x005577 true))

(def *token-format*   (new flash.text.TextFormat nil nil 0x000000 false)) ;; default token format
(def *keyword-format* (new flash.text.TextFormat nil nil 0x008888 true))
(def *int-format*     (new flash.text.TextFormat nil nil 0x440088 true))
(def *float-format*   (new flash.text.TextFormat nil nil 0x8800cc true))
(def *ratio-format*   (new flash.text.TextFormat nil nil 0xcc00ff true))

(def *last-highlighting* 0)
(def *refresh-highlighting* true)
(def *highlighting-interval* 300)

(defn token-format
  "Returns a TextFormat object."
  [token-string]
  (let [reader (. *runtime* lispReader)] ;; use LispReader's number matching regexes
    (cond (= (first token-string) ":") *keyword-format*
          (re-match (. reader intPat)   token-string) *int-format*
          (re-match (. reader floatPat) token-string) *float-format*
          (re-match (. reader ratioPat) token-string) *ratio-format*
          :else *token-format*)))

(defn highlight!
  "Apply syntax highlighting to current buffer."
  []
  (let [tf (buffer-textfield)]
    (. tf (setTextFormat *plain-format*))
    (loop [matches (quick-parse (buffer-string))]
      (if matches
        (let [[match regex quoted open close comment token index] (first matches)]
          (. tf (setTextFormat (cond (seq regex) *regex-format*
                                     (seq quoted) *string-format*
                                     (seq comment) *comment-format*
                                     (seq token) (token-format token)
                                     (or (seq open) (seq close)) *paren-format*
                                     :else *plain-format*)
                               index
                               (+ index (count match))))
          (recur (rest matches))))))
  (def *last-highlighting* (get-timer))
  (def *refresh-highlighting* false))

(defn highlight-frame-handler [e]
  "Check if buffer highlighting should be redone, and if enough time has passed since the last highlight call. Refresh highlighting if needed."
  (if (and *refresh-highlighting*
           (< (+ *last-highlighting* *highlighting-interval*) (get-timer)))
    (do
      (highlight!)
      (def *last-highlighting* (get-timer))
      (def *refresh-highlighting* false))))

(defn highlight-change-handler [e]
  (def *refresh-highlighting* true))

;; Key handlers

(defn eval-buffer
  "Saves all code to local storage, evaluates the code in a buffer (by default the current one). Prints the result in the mini buffer."
  ([] (eval-buffer (current-buffer)))
  ([buffer]
     (save-to-lso!) ;; prepare for impending doom
     (clear-mini-buffer!)
     (let [done-fn (fn [x]
                     (pr x)
                     (. *psymacs* (updateLayout)))]
       (eval (. buffer text)
             done-fn
             done-fn))))

;; Keyboard stuff

(def *kb-map* {})

(defmacro kb
  "Shortcut for flash.ui.Keyboard constants"
  [const]
  `(. flash.ui.Keyboard ~const))

(defn set-key-handler!
  "Sets a function as the handler for a specific keypress. key can be either a character or a key-code, modifiers are a sequence which can contain :ctrl, :alt and :shift."
  [key modifiers handler]
    (def *kb-map*
         (assoc *kb-map*
           {:code (if (string? key)
                    (. (. key (toUpperCase)) (charCodeAt 0))
                    key)
            :modifiers (into #{} modifiers)}
           handler)))

(defn event->keystroke [e]
  "Converts a KEY_DOWN event to a {:code ... :modifiers ...} map."
  (let [modifiers #{}
    modifiers (if (. e ctrlKey) (conj modifiers :ctrl) modifiers)
    modifiers (if (. e altKey) (conj modifiers :alt) modifiers)
    modifiers (if (. e shiftKey) (conj modifiers :shift) modifiers)]
    {:code (. e keyCode) :modifiers modifiers}))

(defn key-down-handler [buffer event]
  (let [cmd (*kb-map* (event->keystroke event))]
    (if cmd
      (do
        (set! (. buffer trackChanges) false)
        (cmd)
        (set! (. buffer trackChanges) true)
        (. buffer (dispatchChangeEvent)))
      (def *print-doc* true))))

;; Setup event listeners and hooks

(. *stage* (addEventListener "enterFrame" context-doc-frame-handler false -20000))
(. *stage* (addEventListener "enterFrame" highlight-frame-handler   false -20000))
(set! (. *psymacs* las3rHighlightHook) highlight-change-handler)
(set! (. *psymacs* keyDownHook) key-down-handler)

;; Setup key handlers

(set-key-handler! (kb F5) [] eval-buffer)

;; Load saved data from local storage

(load-from-lso!)

;; Say hello

(println "Write code and hit F5 to run it.")
(println "To close a tab double-click the x.")

]]>.toString();
    }
}

/*
jp/psyark/psycode/core/history/HistoryEntry.as
*/

class HistoryEntry {
public var index:int;
public var oldText:String;
public var newText:String;

public function HistoryEntry(index:int=0, oldText:String="", newText:String="") {
this.index   = index;
this.oldText = oldText;
this.newText = newText;
}
}



/*
jp/psyark/utils/StringComparator.as
*/

/**
* 文字列の左右一致を数える
*/
class StringComparator {
/**
* @private
*/
internal static function test():void {
var sc:StringComparator = new StringComparator();
var test:Function = function (a:String, b:String, l:int, r:int):void {
sc.compare(a, b);
if (sc.commonPrefixLength != l || sc.commonSuffixLength != r) {
    throw new Error();
}
};
test("Hello World", "Hello World", 11, 0);
test("Hello World", "Hello! World", 5, 6);
test("Hello World", "HelPIYOrld", 3, 3);
test("a", "aB", 1, 0);
test("aBC", "aBCD", 3, 0);
test("Ba", "a", 0, 1);
test("aBC", "DaBC", 0, 3);
test("aXbXc", "aXc", 2, 1);
test("aaaXccc", "aaaXbbbXccc", 4, 3);
}

/**
* 左側の共通文字列長
*/
public var commonPrefixLength:int;

/**
* 右側の共通文字列長
*/
public var commonSuffixLength:int;

/**
* 2つの文字列を比較し、commonPrefixLengthとcommonSuffixLengthをセットする
* 
* @param str1 比較する文字列の一方
* @param str2 比較する文字列の他方
*/
public function compare(str1:String, str2:String):void {
    var minLength:int = Math.min(str1.length, str2.length);
    var step:int, l:int, r:int;
    
    step = Math.pow(2, Math.floor(Math.log(minLength) / Math.log(2)));
    for (l=0; l<minLength; ) {
        if (str1.substr(0, l + step) != str2.substr(0, l + step)) {
            if (step == 1) { break; }
            step >>= 1;
        } else {
            l += step;
        }
    }
    l = Math.min(l, minLength);
    
    minLength -= l;
    
    step = Math.pow(2, Math.floor(Math.log(minLength) / Math.log(2)));
    for (r=0; r<minLength; ) {
        if (str1.substr(-r - step) != str2.substr(-r - step)) {
            if (step == 1) { break; }
            step >>= 1;
        } else {
            r += step;
        }
    }
    r = Math.min(r, minLength);
    
    commonPrefixLength = l;
    commonSuffixLength = r;
}
}



/*
jp/psyark/utils/escapeText.as
*/

function escapeText(str:String):String {
    return EscapeTextInternal.escapeText(str);
}

class EscapeTextInternal {
    private static var table:Object;
    {
        table = {};
        table["\t"] = "\\t";
        table["\r"] = "\\r";
        table["\n"] = "\\n";
        table["\\"] = "\\\\";
    }
    
    public static function escapeText(str:String):String {
        return str.replace(/[\t\r\n\\]/g, replace);
    }
    
    private static function replace(match:String, index:int, source:String):String {
        return table[match];
    }
}



/*
jp/psyark/psycode/core/psycode_internal.as
*/

namespace psycode_internal = "http://psyark.jp/ns/psycode";



/*
jp/psyark/utils/convertNewlines.as
*/

function convertNewlines(str:String, newline:String="\n"):String {
    return str.replace(/\r\n|\r|\n/g, newline);
}



/*
jp/psyark/psycode/core/linenumber/LineNumberView.as
*/

import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;

/**
* 行番号表示
*/
class LineNumberView extends TextField {
    private var target:TextField;
    
    public function LineNumberView(target:TextField) {
        this.target = target;
        
        width = 30;
        background = true;
        backgroundColor = 0xF2F2F2;
        multiline = true;
        selectable = false;
        
        target.addEventListener(Event.CHANGE, updateView);
        target.addEventListener(Event.SCROLL, updateView);
    }
    
    public override function setTextFormat(format:TextFormat, beginIndex:int=-1, endIndex:int=-1):void {
        defaultTextFormat = format;
        super.setTextFormat(format);
        updateView(null);
    }
    
    private function updateView(event:Event):void {
        text = "000\n" + target.numLines;
        width = textWidth + 4;
        text = "";
        for (var i:int=target.scrollV; i<=target.bottomScrollV; i++) {
            appendText(i + "\n");
        }
        dispatchEvent(new Event(Event.RESIZE));
    }
}



/*
jp/psyark/psycode/controls/UIControl.as
*/

import flash.display.Sprite;

class UIControl extends Sprite {
    private var _width:Number = 100;
    private var _height:Number = 100;
    
    
    /**
    * コントロールの幅と高さ設定します。
    */
    public function setSize(width:Number, height:Number):void {
        if (_width != width || _height != height) {
            _width = width;
            _height = height;
            updateSize();
        }
    }
    
    
    /**
    * コントロールの幅を取得または設定します。
    */
    public override function get width():Number {
        return _width;
    }
    
    /**
    * @private
    */
    public override function set width(value:Number):void {
        if (_width != value) {
            _width = value;
            updateSize();
        }
    }
    
    /**
    * コントロールの高さを取得または設定します。
    */
    public override function get height():Number {
        return _height;
    }
    
    /**
    * @private
    */
    public override function set height(value:Number):void {
        if (_height != value) {
            _height = value;
            updateSize();
        }
    }
    
    
    /**
    * コントロールのサイズを更新します。
    */
    protected function updateSize():void {
    }
}



/*
jp/psyark/psycode/controls/ScrollBar.as
*/

import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;

[Event(name="change", type="flash.events.Event")]
class ScrollBar extends UIControl {
    public static const HORIZONTAL:String = "horizontal";
    public static const VERTICAL:String = "vertical";
    public static const BAR_THICKNESS:Number = 16;
    public static const MIN_HANDLE_LENGTH:Number = 14;
    
    
    protected var handle:ScrollBarHandle;
    protected var track:Sprite;
    protected var draggableSize:Number;
    private var handlePressX:Number;
    private var handlePressY:Number;
    private var dragging:Boolean = false;
    
    protected var trackColors:Array = [0xDDDDDD, 0xECECEC, 0xF5F5F5];
    protected var trackAlphas:Array = [1, 1, 1];
    protected var trackRatios:Array = [0x00, 0x2A, 0xFF];
    
    
    private var _direction:String;
    public function get direction():String {
        return _direction;
    }
    
    private var _value:Number = 0;
    public function get value():Number {
        return _value;
    }
    public function set value(v:Number):void {
        if (_value != v) {
            _value = v;
            updateHandle();
        }
    }
    
    private var _maxValue:Number = 1;
    public function get maxValue():Number {
        return _maxValue;
    }
    public function set maxValue(value:Number):void {
        if (_maxValue != value) {
            _maxValue = value;
            updateHandle();
        }
    }
    
    private var _minValue:Number = 0;
    public function get minValue():Number {
        return _minValue;
    }
    public function set minValue(value:Number):void {
        if (_minValue != value) {
            _minValue = value;
            updateHandle();
        }
    }
    
    private var _viewSize:Number = 0;
    public function get viewSize():Number {
        return _viewSize;
    }
    public function set viewSize(value:Number):void {
        if (_viewSize != value) {
            _viewSize = value;
            updateHandle();
        }
    }
    
    public override function get width():Number {
        return direction == VERTICAL ? BAR_THICKNESS : super.width;
    }
    
    public override function get height():Number {
        return direction == HORIZONTAL ? BAR_THICKNESS : super.height;
    }
    
    public function ScrollBar(direction:String="vertical") {
        if (direction == HORIZONTAL || direction == VERTICAL) {
            _direction = direction;
        } else {
            throw new ArgumentError("direction must be " + HORIZONTAL + " or " + VERTICAL + ".");
        }
        
        track = new Sprite();
        track.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler);
        addChild(track);
        
        handle = new ScrollBarHandle(direction);
        handle.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDownHandler);
        addChild(handle);
        invalidateAll();
    }
    
    protected function invalidateAll():void {
        updateTrack();
        updateHandle();
    }
    
    
    /**
    * スクロールバーの表示を更新します。
    */
    protected function updateTrack():void {
        var mtx:Matrix = new Matrix();
        
        track.graphics.clear();
        if (direction == VERTICAL) {
            mtx.createGradientBox(BAR_THICKNESS, height);
            track.graphics.beginGradientFill(GradientType.LINEAR, trackColors, trackAlphas, trackRatios, mtx);
            track.graphics.drawRect(0, 0, BAR_THICKNESS, height);
        } else {
            mtx.createGradientBox(BAR_THICKNESS, height, Math.PI / 2);
            track.graphics.beginGradientFill(GradientType.LINEAR, trackColors, trackAlphas, trackRatios, mtx);
            track.graphics.drawRect(0, 0, width, BAR_THICKNESS);
        }
    }
    
    
    protected function updateHandle():void {
        if (maxValue > minValue) {
            var t:Number = Math.max(minValue, Math.min(maxValue, value));
            if (value != t) {
                value = t;
                dispatchEvent(new Event(Event.CHANGE));
            }
            
            handle.visible = true;
            if (direction == VERTICAL) {
                var handleHeight:Number = MIN_HANDLE_LENGTH + (height - MIN_HANDLE_LENGTH) * viewSize / (maxValue - minValue + viewSize);
                draggableSize = height - handleHeight;
                handle.setSize(BAR_THICKNESS - 1, handleHeight);
                handle.x = 1;
                if (dragging == false) {
                    handle.y = (value - minValue) / (maxValue - minValue) * draggableSize;
                }
            } else {
                var handleWidth:Number = MIN_HANDLE_LENGTH + (width - MIN_HANDLE_LENGTH) * viewSize / (maxValue - minValue + viewSize);
                draggableSize = width - handleWidth;
                handle.setSize(handleWidth, BAR_THICKNESS - 1);
                handle.y = 1;
                if (dragging == false) {
                    handle.x = (value - minValue) / (maxValue - minValue) * draggableSize;
                }
            }
        } else {
            handle.visible = false;
        }
    }
    
    protected function trackMouseDownHandler(event:MouseEvent):void {
        
    }
    
    protected function handleMouseDownHandler(event:MouseEvent):void {
        stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
        handlePressX = mouseX - handle.x;
        handlePressY = mouseY - handle.y;
        dragging = true;
    }
    
    protected function stageMouseMoveHandler(event:MouseEvent):void {
        event.updateAfterEvent();
        var position:Number;
        if (direction == VERTICAL) {
            position = handle.y = Math.max(0, Math.min(draggableSize, mouseY - handlePressY));
        } else {
            position = handle.x = Math.max(0, Math.min(draggableSize, mouseX - handlePressX));
        }
        var newValue:Number = (position / draggableSize) * (maxValue - minValue) + minValue;
        if (_value != newValue) {
            _value = newValue;
            dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    protected function stageMouseUpHandler(event:MouseEvent):void {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
        dragging = false;
    }
    
    protected override function updateSize():void {
        invalidateAll();
    }
}



/*
jp/psyark/psycode/controls/TextScrollBar.as
*/

import flash.events.Event;
import flash.text.TextField;

class TextScrollBar extends ScrollBar {
    private var target:TextField;
    
    public function TextScrollBar(target:TextField, direction:String="vertical") {
        this.target = target;
        super(direction);
        
        if (direction == VERTICAL) {
            minValue = 1;
            value = 1;
        }
        
        addEventListener(Event.CHANGE, changeHandler);
        target.addEventListener(Event.CHANGE, targetChangeHandler);
        target.addEventListener(Event.SCROLL, targetScrollHandler);
        
        targetChangeHandler(null);
        targetScrollHandler(null);
    }
    
    private function changeHandler(event:Event):void {
        if (direction == VERTICAL) {
            target.scrollV = Math.round(value);
        } else {
            target.scrollH = Math.round(value);
        }
    }
    
    private function targetChangeHandler(event:Event):void {
        correctTextFieldScrollPosition(target);
        if (direction == VERTICAL) {
            maxValue = target.maxScrollV;
            viewSize = target.bottomScrollV - target.scrollV;
        } else {
            maxValue = target.maxScrollH;
            viewSize = target.width;
        }
    }
    
    private function targetScrollHandler(event:Event):void {
        correctTextFieldScrollPosition(target);
        if (direction == VERTICAL) {
            value = target.scrollV;
        } else {
            value = target.scrollH;
        }
    }
    
    protected override function updateSize():void {
        super.updateSize();
        targetChangeHandler(null);
    }
    
    
    /**
    * 時折不正確な値を返すTextField#scrollVが、正しい値を返すようにする
    */
    protected static function correctTextFieldScrollPosition(target:TextField):void {
        // textWidthかtextHeightにアクセスすればOK
        target.textWidth;
        target.textHeight;
    }
}



/*
jp/psyark/psycode/core/TextEditUI.as
*/

import flash.events.Event;
import flash.events.FocusEvent;
import flash.net.FileReference;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

/**
* @private
* TextEditAreaクラスは、テキストフィールド・行番号・スクロールバーなど
* テキスト編集UIの基本的な機能を提供し、それらの実装を隠蔽します。
*/
class TextEditUI extends UIControl {
    protected var linumField:LineNumberView;
    protected var scrollBarV:TextScrollBar;
    protected var scrollBarH:TextScrollBar;
    public var textField:TextField;
    
    private var TAB_STOP_RATIO:Number = 2.42;
    private var fileRef:FileReference;
    
    
    /**
    * TextEditUIクラスのインスタンスを初期化します。
    */
    public function TextEditUI() {
        var tabStops:Array = [];
        for (var i:int=1; i<20; i++) {
            tabStops.push(13 * TAB_STOP_RATIO * i);
        }
        var fmt:TextFormat = new TextFormat("Courier New", 13, 0x000000);
        fmt.tabStops = tabStops;
        fmt.leading = 1;
        
        textField = new TextField();
        textField.background = true;
        textField.backgroundColor = 0xFFFFFF;
        textField.multiline = true;
        textField.type = TextFieldType.INPUT;
        textField.defaultTextFormat = fmt;
        textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function (event:FocusEvent):void {
                event.preventDefault();
            });
        
        fmt.align = TextFormatAlign.RIGHT;
        fmt.color = 0x666666;
        
        linumField = new LineNumberView(textField);
        linumField.setTextFormat(fmt);
        linumField.addEventListener(Event.RESIZE, linumResizeHandler);
        
        scrollBarV = new TextScrollBar(textField);
        scrollBarH = new TextScrollBar(textField, ScrollBar.HORIZONTAL);
        
        addChild(textField);
        addChild(linumField);
        addChild(scrollBarV);
        addChild(scrollBarH);
        
        updateSize();
        
        textField.addEventListener(Event.SCROLL, textFieldScrollHandler);
    }
    
    public function open():void {
        fileRef = new FileReference();
        fileRef.addEventListener(Event.SELECT, function (event:Event):void {
                fileRef.load();
            });
        fileRef.addEventListener(Event.COMPLETE, function (event:Event):void {
                text = convertNewlines(String(fileRef.data));
            });
        fileRef.browse();
    }
    
    public function save():void {
        var localName:String; // TODO: = CodeUtil.getDefinitionLocalName(text);
        localName ||= "untitled";
        fileRef = new FileReference();
        fileRef.save(text, localName + ".lsr");
    }
    
    public function setFontSize(fontSize:Number):void {
        var tabStops:Array = [];
        for (var i:int=1; i<20; i++) {
            tabStops.push(i * fontSize * 2.42);
        }
        
        var fmt:TextFormat = textField.defaultTextFormat;
        fmt.size = fontSize;
        fmt.tabStops = tabStops;
        textField.defaultTextFormat = fmt;
        
        fmt.align = TextFormatAlign.RIGHT;
        fmt.color = 0x666666;
        linumField.setTextFormat(fmt);
        
        fmt = new TextFormat();
        fmt.size = fontSize;
        fmt.tabStops = tabStops;
        textField.setTextFormat(fmt);
        
        dispatchChangeEvent();
    }
    
    
    private function textFieldScrollHandler(event:Event):void {
        dispatchEvent(event);
    }
    
    private function linumResizeHandler(event:Event):void {
        updateSize();
    }
    
    
    /**
    * テキストフィールドへのアクセスを提供します
    */
    public function get text():String {
        return textField.text;
    }
    public function set text(value:String):void {
        textField.text = value;
        dispatchChangeEvent();
    }
    public function get selectionBeginIndex():int {
        return textField.selectionBeginIndex;
    }
    public function get selectionEndIndex():int {
        return textField.selectionEndIndex;
    }
    public function setSelection(beginIndex:int, endIndex:int):void {
        textField.setSelection(beginIndex, endIndex);
    }
    public function replaceText(beginIndex:int, endIndex:int, newText:String):void {
        textField.replaceText(beginIndex, endIndex, convertNewlines(newText));
    }
    public function replaceSelectedText(newText:String):void {
        textField.replaceSelectedText(newText);
    }
    psycode_internal function setTextFormat(format:TextFormat, beginIndex:int=-1, endIndex:int=-1):void {
        textField.setTextFormat(format, beginIndex, endIndex);
    }
    psycode_internal function resetFocus():void {
        if (stage.focus) {
            throw 1;
        }
        stage.focus = textField;
    }
    
    public function dispatchChangeEvent():void {
        textField.dispatchEvent(new Event(Event.CHANGE, true));
    }
    
    /**
    * エディタのレイアウトを更新します。
    */
    protected override function updateSize():void {
        linumField.height = height;
        textField.x = linumField.width;
        textField.width = width - scrollBarV.width - linumField.width;
        textField.height = height - scrollBarH.height;
        scrollBarV.x = width - scrollBarV.width;
        scrollBarV.height = height - scrollBarH.height;
        scrollBarH.x = linumField.width;
        scrollBarH.y = height - scrollBarH.height;
        scrollBarH.width = width - scrollBarV.width - linumField.width;
        graphics.clear();
        graphics.beginFill(0xEEEEEE);
        graphics.drawRect(0, 0, width, height);
    }
}



/*
jp/psyark/utils/callLater.as
*/

function callLater(func:Function, args:Array=null, frame:int=1):void {
    Helper.callLater(func, args, frame);
}

import flash.display.MovieClip;
import flash.events.Event;

class Helper {
    private static var engine:MovieClip = new MovieClip();
    
    public static function callLater(func:Function, args:Array=null, frame:int=1):void {
        engine.addEventListener(Event.ENTER_FRAME, function(event:Event):void {
                if (--frame <= 0) {
                    engine.removeEventListener(Event.ENTER_FRAME, arguments.callee);
                    func.apply(null, args);
                }
            });
    }
}


/*
jp/psyark/psycode/core/history/HistoryManager.as
*/

import __AS3__.vec.Vector;

class HistoryManager {
    private var currentIndex:int = 0;
    private var entries:Vector.<HistoryEntry>;
    
    public function HistoryManager() {
        entries = new Vector.<HistoryEntry>();
    }
    
    public function appendEntry(entry:HistoryEntry):void {
        entries.length = currentIndex;
        entries.push(entry);
        currentIndex = entries.length;
    }
    
    public function clear():void {
        currentIndex = 0;
        entries.length = 0;
    }
    
    public function get canForward():Boolean {
        return currentIndex < entries.length;
    }
    
    public function get canBack():Boolean {
        return currentIndex > 0;
    }
    
    public function forward():HistoryEntry {
        return entries[currentIndex++];
    }
    
    public function back():HistoryEntry {
        return entries[--currentIndex];
    }
}


/*
jp/psyark/psycode/core/TextEditorBase.as
*/

import flash.events.Event;
import flash.events.TextEvent;
import flash.geom.Rectangle;


/**
* @private
* TextEditorBaseクラスはTextEditUIクラスを継承し、
* キーイベントのキャンセルなどテキストエディタの実装に必要な機能を提供します。
*/
class TextEditorBase extends TextEditUI {
    public var preventFollowingTextInput:Boolean = false;
    public var prevText:String = "";
    public var prevSBI:int;
    public var prevSEI:int;
    
    public var trackChanges:Boolean = true;
    protected var ignoreChange:Boolean = false;
    public var comparator:StringComparator;
    protected var historyManager:HistoryManager;
    
    /**
    * TextEditorBaseクラスのインスタンスを作成します。
    */
    public function TextEditorBase() {
        addEventListener(Event.CHANGE, changeHandler);
        addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
    }
    
    
    /**
    * 次のテキスト入力をキャンセルするように、現在の状態を保存します。
    */
    psycode_internal function preventNextTextInput():void {
        
    }
    
    
    /**
    * テキストが変更された
    */
    private function changeHandler(event:Event):void {
        if(Psymacs.instance.las3rHighlightHook != null) {
            Psymacs.instance.las3rHighlightHook(event);
        }
        //trace("change", "changed=" + (prevText != text), "ignore=" + ignoreChange, "prevent=" + preventFollowingTextInput);
        //trace("{" + escapeText(prevText) + "} => {" + escapeText(text) + "}");
        if (prevText != text) {
            if (preventFollowingTextInput) {
                comparator.compare(prevText, text);
                replaceText(
                    comparator.commonPrefixLength,
                    text.length - comparator.commonSuffixLength,
                    prevText.substring(comparator.commonPrefixLength, prevText.length - comparator.commonSuffixLength)
                );
                setSelection(prevSBI, prevSEI);
                preventFollowingTextInput = false;
            } else if (trackChanges){
                comparator.compare(prevText, text);
                if (!ignoreChange) {
                    var entry:HistoryEntry = new HistoryEntry(comparator.commonPrefixLength);
                    entry.oldText = prevText.substring(comparator.commonPrefixLength, prevText.length - comparator.commonSuffixLength);
                    entry.newText = text.substring(comparator.commonPrefixLength, text.length - comparator.commonSuffixLength);
                    historyManager.appendEntry(entry);
                }
                //callLater(syntaxHighlighter.update, [comparator.commonPrefixLength, text.length - comparator.commonSuffixLength]);
                prevText = text;
            }
        }
    }
    
    
    /**
    * テキストが入力された
    */
    private function textInputHandler(event:TextEvent):void {
        if (preventFollowingTextInput) {
            event.preventDefault();
        }
    }
    
    
    /**
    * 履歴追加の際、自分が無視できる変更イベントを送信
    */
    protected function dispatchIgnorableChangeEvent():void {
        ignoreChange = true;
        dispatchChangeEvent();
        ignoreChange = false; 
    }
    
    /**
    * インポート文の自動追加
    */
    private function autoImport(qname:String):void {
        var regex:String = "";
        regex += "(package\\s*(?:[_a-zA-Z]\\w*(?:\\.[_a-zA-Z]\\w*)*)?\\s*{)"; // package
            regex += "(\\s*(?:import\\s*(?:[_a-zA-Z]\\w*(?:\\.[_a-zA-Z]\\w*)*(?:\\.\\*)?[\\s;]+))*$)"; // import 
            regex += "(.*?public\\s+(?:class|interface|function|namespace))"; // def
            var match:Array = text.match(new RegExp(regex, "sm"));
            if (match) {
                var importTable:Object = {};
                match[2].replace(/import\s*([_a-zA-Z]\w*(?:\.[_a-zA-Z]\w*)*(?:\.\*)?)/g, function (match:String, cap1:String, index:int, source:String):void {
                        importTable[cap1] = true;
                    });
                importTable[qname] = true;
                var importList:Array = [];
                for (var i:String in importTable) {
                    importList.push("\timport " + i + ";");
                }
                var importStr:String = importList.sort().join("\n");
                var newStr:String = "\n" + importStr + "\n" + match[3];
                var index:int = selectionBeginIndex;
                replaceText(
                    match.index + match[1].length,
                    match.index + match[1].length + match[2].length + match[3].length,
                    newStr
                );
                
                if (index > match.index + match[1].length) {
                    var newSel:int = index + newStr.length - match[2].length - match[3].length;
                    setSelection(newSel, newSel);
                }
                dispatchChangeEvent();
            }
        }
    }



    /*
    jp/psyark/psycode/controls/ScrollBarHandle.as
    */

    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.SimpleButton;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;


    class ScrollBarHandle extends SimpleButton {
        protected static var handleColors:Array = [0xF7F7F7, 0xECECEC, 0xD8D8D8, 0xCCCCCC, 0xEDEDED];
        protected static var handleAlphas:Array = [1, 1, 1, 1, 1];
        protected static var handleRatios:Array = [0x00, 0x66, 0x80, 0xDD, 0xFF];
        protected static var iconColors:Array = [0x000000, 0xFFFFFF];
        protected static var iconAlphas:Array = [1, 1];
        protected static var iconRatios:Array = [0x00, 0xFF];
        
        private var direction:String;
        private var upFace:Shape;
        private var overFace:Shape;
        
        public function ScrollBarHandle(direction:String="vertical") {
            this.direction = direction;
            cacheAsBitmap = true;
            useHandCursor = false;
            
            upFace = new Shape();
            overFace = new Shape();
            overFace.transform.colorTransform = new ColorTransform(0.95, 1.3, 1.5, 1, 0x00, -0x33, -0x44);
            
            upState = upFace;
            overState = overFace;
            downState = overFace;
            hitTestState = upFace;
        }
        
        public function setSize(w:Number, h:Number):void {
            drawFace(upFace.graphics, w, h);
            drawFace(overFace.graphics, w, h);
        }
        
        protected function drawFace(graphics:Graphics, w:Number, h:Number):void {
            var mtx:Matrix = new Matrix();
            mtx.createGradientBox(w, h, direction == ScrollBar.VERTICAL ? 0 : Math.PI / 2);
            
            graphics.clear();
            graphics.beginFill(0x999999);
            graphics.drawRoundRect(0, 0, w, h, 2);
            graphics.beginGradientFill(GradientType.LINEAR, handleColors, handleAlphas, handleRatios, mtx);
            graphics.drawRect(1, 1, w - 2, h - 2);
            
            graphics.lineStyle(-1, 0xEEEEEE);
            graphics.beginGradientFill(GradientType.LINEAR, iconColors, iconAlphas, iconRatios, mtx);
            for (var i:int=-1; i<2; i++) {
                if (direction == ScrollBar.VERTICAL) {
                    graphics.drawRoundRect((w - 8) / 2, (h - 3) / 2 + i * 3, 8, 3, 2);
                } else {
                    graphics.drawRoundRect((w - 3) / 2 + i * 3, (h - 8) / 2, 3, 8, 2);
                }
            }
        }
    }



    /*
    jp/psyark/psycode/controls/ListItemRenderer.as
    */

    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;

    class ListItemRenderer extends UIControl {
        private var _data:Object;
        private var _labelField:String;
        private var label:TextField;
        
        public function ListItemRenderer() {
            label = new TextField();
            label.selectable = false;
            label.defaultTextFormat = new TextFormat("Courier New", 13, 0x000000);
            label.backgroundColor = 0xE8F8FF;
            addChild(label);
            updateView();
            
            addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
            addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
        }
        
        public function get data():Object {
            return _data;
        }
        
        public function set data(value:Object):void {
            if (_data != value) {
                _data = value;
                updateView();
            }
        }
        
        /**
        * ラベルとして使うプロパティ名を取得または設定します。
        */
        public function get labelField():String {
            return _labelField;
        }
        
        /**
        * @private
        */
        public function set labelField(value:String):void {
            if (_labelField != value) {
                _labelField = value;
                updateView();
            }
        }
        
        protected function updateView():void {
            if (data) {
                try {
                    label.text = data[labelField];
                } catch (e:*) {
                    label.text = "";
                }
                label.visible = true;
            } else {
                label.visible = false;
            }
        }
        
        protected override function updateSize():void {
            label.width = width;
            label.height = height;
        }
        
        protected function rollOverHandler(event:MouseEvent):void {
            label.background = true;
        }
        
        protected function rollOutHandler(event:MouseEvent):void {
            label.background = false;
        }
    }


    /*
    jp/psyark/psycode/controls/TabView.as
    */

    import flash.display.DisplayObject;
    import flash.display.GradientType;
    import flash.display.Shape;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.utils.Dictionary;

    class TabView extends UIControl {
        private var contentItemTable:Dictionary;
        public var items:Array;
        private var addButton:SimpleButton;
        
        private var _currentItem:TabViewItem;
        private function get currentItem():TabViewItem {
            return _currentItem;
        }
        private function set currentItem(value:TabViewItem):void {
            if (_currentItem != value) {
                if (_currentItem) {
                    removeChild(_currentItem.content);
                }
                _currentItem = value;
                if (_currentItem) {
                    addChild(_currentItem.content);
                    updateView();
                }
                if(Psymacs.instance.las3rHighlightHook != null) {
                    Psymacs.instance.las3rHighlightHook(null);
                }
            }
        }
        
        public function get selectedIndex():int {
            return items.indexOf(currentItem);
        }
        
        public function TabView() {
            contentItemTable = new Dictionary();
            items = new Array();
            addButton = createAddButton();
            addButton.addEventListener(MouseEvent.CLICK, addButtonClickHandler);
            addChild(addButton);
        }
        
        private function createAddButton():SimpleButton {
            var u:Shape = new Shape();
            var o:Shape = new Shape();
            
            o.graphics.beginFill(0x666666);
            o.graphics.drawRoundRect(0, 0, 18, 18, 8);
            o.graphics.beginFill(0xFFFFFF);
            o.graphics.drawRoundRect(1, 1, 16, 16, 6);
            for each (var shape:Shape in [u, o]) {
                shape.graphics.beginFill(0x666666);
                shape.graphics.drawRect(7, 4, 4, 10);
                shape.graphics.beginFill(0x666666);
                shape.graphics.drawRect(4, 7, 10, 4);
                shape.graphics.beginFill(0xFFFFFF);
                shape.graphics.drawRect(8, 5, 2, 8);
                shape.graphics.beginFill(0xFFFFFF);
                shape.graphics.drawRect(5, 8, 8, 2);
            }
            
            var btn:SimpleButton = new SimpleButton();
            btn.upState = u;
            btn.overState = o;
            btn.downState = o;
            btn.hitTestState = o;
            return btn;
        }
        
        public function addItem(content:DisplayObject, title:String):void {
            var item:TabViewItem = new TabViewItem(content, title);
            item.addEventListener(Event.CLOSE, itemCloseHandler);
            item.addEventListener(MouseEvent.CLICK, itemClickHandler);
            items.push(item);
            addChild(item);
            contentItemTable[content] = item;
            currentItem = item;
            updateView();
        }
        
        public function addItemWithText(content:String, title:String):void {
            var editor:TextEditor = new TextEditor;

                        editor.trackChanges = false;
            editor.textField.text = content;
            editor.prevText = content;
                        editor.trackChanges = true;
            addItem(editor, title);
        }

        public function setTitle(content:DisplayObject, title:String):void {
            TabViewItem(contentItemTable[content]).title = title;
            updateView();
        }
        
        public function removeItem(content:DisplayObject):void {
            var item:TabViewItem = contentItemTable[content];
            items.splice(items.indexOf(item), 1);
            removeChild(item);
            delete contentItemTable[content];
            if (currentItem == item) {
                currentItem = items[0];
            }
            updateView();
        }
        
        public function get count():int {
            return items.length;
        }
        
        public function getItemAt(index:int):DisplayObject {
            return TabViewItem(items[index]).content;
        }
        
        private function itemClickHandler(event:MouseEvent):void {
            currentItem = TabViewItem(event.currentTarget);
        }
        
        private function itemCloseHandler(event:Event):void {
            removeItem(TabViewItem(event.currentTarget).content);
        }
        
        private function addButtonClickHandler(event:MouseEvent):void {
            dispatchEvent(new Event(Event.OPEN));
        }
        
        public function updateView():void {
            graphics.clear();
            graphics.beginFill(0x999999);
            graphics.drawRoundRect(0, 0, width, height, 8);
            graphics.beginFill(0xEEEEEE);
            graphics.drawRoundRect(1, 1, width - 2, height - 2, 6);
            graphics.beginFill(0x999999);
            graphics.drawRect(0, 22, width, height - 22);
            graphics.beginFill(0xC1CFDD);
            graphics.drawRect(1, 23, width - 2, height - 24);
            graphics.beginFill(0xFFFFFF);
            graphics.drawRect(4, 26, width - 8, height - 30);
            
            var left:Number = 1;
            for each (var item:TabViewItem in items) {
                item.x = left;
                item.y = 1;
                left += item.width;
            }
            addButton.x = left + 3;
            addButton.y = 2;
            
            if (currentItem) {
                var mtx:Matrix = new Matrix();
                mtx.createGradientBox(10, 20, Math.PI / 2);
                graphics.beginGradientFill(GradientType.LINEAR, [0xD3DFEE, 0xC1CFDD], [1, 1], [0x00, 0xFF], mtx);
                graphics.drawRect(currentItem.x, currentItem.y, currentItem.width, currentItem.height);
                
                currentItem.content.x = 4;
                currentItem.content.y = 26;
                if (currentItem.content is UIControl) {
                    UIControl(currentItem.content).setSize(width - 8, height - 30);
                }
            }
        }
        
        protected override function updateSize():void {
            super.updateSize();
            updateView();
        }
    }

    import flash.display.Sprite;
    import flash.display.DisplayObject;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.display.Shape;
    import flash.display.SimpleButton;
    import flash.events.MouseEvent;
    import flash.events.Event;  

    class TabViewItem extends Sprite {
        private var label:TextField;
        private var closeButton:SimpleButton;
        public var content:DisplayObject;
        
        public function get title():String {
            return label.text;
        }
        public function set title(value:String):void {
            label.text = value;
            updateView();
        }
        
        public function TabViewItem(content:DisplayObject, title:String):void {
            var fmt:TextFormat = new TextFormat("_sans");
            fmt.leftMargin = 4;
            fmt.rightMargin = 4;
            
            label = new TextField();
            label.selectable = true;
            label.type = TextFieldType.INPUT;
            label.defaultTextFormat = fmt;
            label.addEventListener(Event.CHANGE, 
                function(e:Event):void { 
                    updateView();
                    Psymacs.instance.tabView.updateView();
                });
            addChild(label);
            
            closeButton = createCloseButton();
			closeButton.doubleClickEnabled = true;
            closeButton.addEventListener(MouseEvent.DOUBLE_CLICK, closeButtonClickHandler);
            addChild(closeButton);
            
            this.title = title;
            this.content = content;
        }
        
        private function updateView():void {
            label.width = Math.max(60, Math.min(140, label.textWidth + 30));
            label.height = label.textHeight + 4;
            label.y = (20 - label.height) / 2;
            graphics.clear();
            graphics.lineStyle(-1, 0x999999);
            graphics.moveTo(label.width, 0);
            graphics.lineTo(label.width, 22);
            
            closeButton.rotation = 45;
            closeButton.x = label.width - 11;
            closeButton.y = 11;
        }
        
        private function createCloseButton():SimpleButton {
            var u:Shape = new Shape();
            var o:Shape = new Shape();
            
            //o.graphics.beginFill(0xEEEEEE);
            o.graphics.drawCircle(0, 0, 10);
            for each (var shape:Shape in [u, o]) {
                shape.graphics.beginFill(0x666666);
                shape.graphics.drawRect(-2, -6, 4, 12);
                shape.graphics.beginFill(0x666666);
                shape.graphics.drawRect(-6, -2, 12, 4);
                shape.graphics.beginFill(0xFFFFFF);
                shape.graphics.drawRect(-1, -5, 2, 10);
                shape.graphics.beginFill(0xFFFFFF);
                shape.graphics.drawRect(-5, -1, 10, 2);
            }
            
            var btn:SimpleButton = new SimpleButton();
            btn.upState = u;
            btn.overState = o;
            btn.downState = u;
            btn.hitTestState = o;
            return btn;
        }
        
        private function closeButtonClickHandler(event:MouseEvent):void {
            dispatchEvent(new Event(Event.CLOSE));
            event.stopPropagation();
        }
    }


    /*
    jp/psyark/psycode/TextEditor.as
    */

    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.net.FileReference;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;

    /**
    * TextEditorクラス
    */
    class TextEditor extends TextEditorBase {
        private var highlightAllTimer:int;
        
        /**
        * コンストラクタ
        */
        public function TextEditor() {
            comparator = new StringComparator();
            historyManager = new HistoryManager();
            
            contextMenu = createDebugMenu();
            
            addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            addEventListener(Event.CHANGE, function (event:Event):void {
                    clearTimeout(highlightAllTimer);
                    highlightAllTimer = setTimeout(highlightAll, 1000);
                });
        }
        
        private function highlightAll():void {
            //syntaxHighlighter.update(0, text.length);
        }
        
        
        private function createDebugMenu():ContextMenu {
            var menu:ContextMenu = new ContextMenu();
            menu.hideBuiltInItems();
            createMenuItem("ファイルを開く(&O)...", open);
            createMenuItem("ファイルを保存(&S)...", save);
            createMenuItem("元に戻す(&Z)", undo, function ():Boolean { return historyManager.canBack; }, true);
            createMenuItem("やり直し(&Y)", redo, function ():Boolean { return historyManager.canForward; });
            createMenuItem("文字サイズ : &64", function ():void { setFontSize(64); }, null, true);
            createMenuItem("文字サイズ : &48", function ():void { setFontSize(48); });
            createMenuItem("文字サイズ : &32", function ():void { setFontSize(32); });
            createMenuItem("文字サイズ : &24", function ():void { setFontSize(24); });
            createMenuItem("文字サイズ : &13", function ():void { setFontSize(13); });
            return menu;
            
            function createMenuItem(caption:String, func:Function, enabler:Function=null, separator:Boolean=false):void {
                var item:ContextMenuItem = new ContextMenuItem(caption, separator);
                item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function (event:ContextMenuEvent):void {
                        func();
                    });
                if (enabler != null) {
                    menu.addEventListener(ContextMenuEvent.MENU_SELECT, function (event:ContextMenuEvent):void {
                            item.enabled = enabler();
                        });
                }
                menu.customItems.push(item);
            }
        }
        
        
        /**
        * 履歴を消去
        */
        public function clearHistory():void {
            historyManager.clear();
            prevText = text;
        }
        
        
        /**
        * キー押下イベントハンドラ
        */
        private function keyDownHandler(event:KeyboardEvent):void {
            preventFollowingTextInput = false;

            if (event.keyCode == 90 && event.ctrlKey && !event.altKey) {
                if(event.shiftKey) {
                    // Ctrl+Shift+Z : REDO
                    redo();
                } else {
                    // Ctrl+Z : UNDO
                    undo();
                }
                event.preventDefault();
                preventFollowingTextInput = true;
                prevSBI = selectionBeginIndex;
                prevSEI = selectionEndIndex;
                return;
            }

            if(null != Psymacs.instance.keyDownHook) Psymacs.instance.keyDownHook(this, event);
            return;

            
            // Ctrl+O : ファイルを開く
            if (event.charCode == "o".charCodeAt(0) && event.ctrlKey) {
                open();
                event.preventDefault();
                preventFollowingTextInput = true;
                prevSBI = selectionBeginIndex;
                prevSEI = selectionEndIndex;
                return;
            }
            
            // Ctrl+S : ファイルを保存
            if (event.charCode == "s".charCodeAt(0) && event.ctrlKey) {
                save();
                event.preventDefault();
                preventFollowingTextInput = true;
                prevSBI = selectionBeginIndex;
                prevSEI = selectionEndIndex;
                return;
            }
            
            // Ctrl+Backspace : 文字グループを前方消去
            if (event.keyCode == Keyboard.BACKSPACE && event.ctrlKey) {
                deleteGroupBack();
                event.preventDefault();
                preventFollowingTextInput = true;
                prevSBI = selectionBeginIndex;
                prevSEI = selectionEndIndex;
                return;
            }
            
            // Tab : タブ挿入とインデント
            if (event.keyCode == Keyboard.TAB) {
                doTab(event);
                return;
            }
            
            // Enter : 自動インデント
            if (event.keyCode == Keyboard.ENTER) {
                doEnter(event);
                return;
            }
            
            // } : 自動アンインデント
            if (event.charCode == 125) {
                doRightbrace(event);
                return;
            }
            
            // Ctrl+Z : UNDO
            if (event.keyCode == 90 && event.ctrlKey) {
                undo();
                event.preventDefault();
                preventFollowingTextInput = true;
                prevSBI = selectionBeginIndex;
                prevSEI = selectionEndIndex;
                return;
            }
            
            // Ctrl+Y : REDO
            if (event.keyCode == 89 && event.ctrlKey) {
                redo();
                event.preventDefault();
                preventFollowingTextInput = true;
                prevSBI = selectionBeginIndex;
                prevSEI = selectionEndIndex;
                return;
            }
        }
        
        
        /**
        * 同じ文字グループを前方消去
        */
        private function deleteGroupBack():void {
            if (selectionBeginIndex != selectionEndIndex) {
                // 範囲選択中なら、範囲を削除
                replaceSelectedText("");
                dispatchChangeEvent();
            } else if (selectionBeginIndex == 0) {
                // カーソル位置が先頭なら、何もしない
            } else {
                var len:int;
                var c:String = text.charAt(selectionBeginIndex - 1);
                if (c == "\r" || c == "\n") {
                    // 改行の直後なら、それを消去
                    len = 1;
                } else {
                    // それ以外なら、同じ文字グループ（単語構成文字・空白・それ以外）を前方消去
                    var match:Array = beforeSelection.match(/(?:\w+|[ \t]+|[^\w \t\r\n]+)$/i);
                    len = match[0].length;
                }
                var newIndex:int = selectionBeginIndex - len;
                replaceText(selectionBeginIndex - len, selectionEndIndex, "");
                setSelection(newIndex, newIndex);
                dispatchChangeEvent();
            }
        }
        
        
        
        
        /**
        * Tab : タブ挿入とインデント
        */
        private function doTab(event:KeyboardEvent):void {
            if (selectionBeginIndex != selectionEndIndex) {
                var b:int, e:int, c:String;
                for (b=selectionBeginIndex; b>0; b--) {
                    c = text.charAt(b - 1);
                    if (c == "\r" || c == "\n") {
                        break;
                    }
                }
                for (e=selectionEndIndex; e<text.length; e++) {
                    c = text.charAt(e);
                    if (c == "\r" || c == "\n") {
                        break;
                    }
                }
                var replacement:String = text.substring(b, e);
                if (event.shiftKey) {
                    replacement = replacement.replace(/^\t/mg, "");
                } else {
                    replacement = replacement.replace(/^(.?)/mg, "\t$1");
                }
                replaceText(b, e, replacement);
                setSelection(b, b + replacement.length);
                dispatchChangeEvent();
                event.preventDefault();
                preventFollowingTextInput = true;
            } else {
                // 選択してなければタブ挿入
                replaceSelectedText("\t");
                setSelection(selectionEndIndex, selectionEndIndex);
                dispatchChangeEvent();
                event.preventDefault();
                preventFollowingTextInput = true;
            }
        }
        
        /**
        * Enter : 自動インデント
        */
        private function doEnter(event:KeyboardEvent):void {
            var before:String = beforeSelection;
            var match:Array = before.match(/(?:^|\n|\r)([ \t]*).*$/);
            var ins:String = "\n" + match[1];
            if (before.charAt(before.length - 1) == "{") {
                ins += "\t";
            }
            replaceSelectedText(ins);
            setSelection(selectionEndIndex, selectionEndIndex);
            dispatchChangeEvent();
            event.preventDefault();
            preventFollowingTextInput = true;
        }
        
        /**
        * } : 自動アンインデント
        */
        private function doRightbrace(event:KeyboardEvent):void {
            var match:Array = beforeSelection.match(/[\r\n]([ \t]*)$/);
            if (match) {
                var preCursorWhite:String = match[1];
                var nest:int = 1;
                for (var i:int=selectionBeginIndex-1; i>=0; i--) {
                    var c:String = text.charAt(i);
                    if (c == "{") {
                        nest--;
                        if (nest == 0) {
                            match = text.substr(0, i).match(/(?:^|[\r\n])([ \t]*)[^\r\n]*$/);
                            var replaceWhite:String = match ? match[1] : "";
                            replaceText(
                                selectionBeginIndex - preCursorWhite.length,
                                selectionEndIndex,
                                replaceWhite + "}"
                            );
                            dispatchChangeEvent();
                            event.preventDefault();
                            preventFollowingTextInput = true;
                            break;
                        }
                    } else if (c == "}") {
                        nest++;
                    }
                }
            }
        }

        /**
        * 元に戻す
        */
        public function undo():void {
            if (historyManager.canBack) {
                var entry:HistoryEntry = historyManager.back();
                replaceText(entry.index, entry.index + entry.newText.length, entry.oldText);
                setSelection(entry.index + entry.oldText.length, entry.index + entry.oldText.length);
                dispatchIgnorableChangeEvent();
            }
        }

        /**
        * やり直し
        */
        public function redo():void {
            if (historyManager.canForward) {
                var entry:HistoryEntry = historyManager.forward();
                replaceText(entry.index, entry.index + entry.oldText.length, entry.newText);
                setSelection(entry.index + entry.newText.length, entry.index + entry.newText.length);
                dispatchIgnorableChangeEvent();
            }
        }

        /**
        * 選択範囲の前の文字列
        */
        private function get beforeSelection():String {
            return text.substr(0, selectionBeginIndex);
        }
    }

    class MiniBuffer extends TextEditUI {
        public function MiniBuffer() {
            linumField.visible = false;
            textField.type = "dynamic";
            textField.wordWrap = true;
        }

        protected override function updateSize():void {
            textField.y = linumField.y = scrollBarV.y = scrollBarH.height;
            linumField.height = height - scrollBarH.height;
            textField.x = scrollBarV.width;
            textField.width = width - scrollBarV.width * 2;
            textField.height = height - scrollBarH.height * 2;
            scrollBarV.x = width - scrollBarV.width;
            scrollBarV.height = height - scrollBarH.height * 2;
            scrollBarH.x = scrollBarV.width;
            scrollBarH.y = height - scrollBarH.height;
            scrollBarH.width = width - scrollBarV.width * 2;
            graphics.clear();
            graphics.beginFill(0xEEEEEE);
            graphics.drawRect(0, 0, width, height);
        }
    }
