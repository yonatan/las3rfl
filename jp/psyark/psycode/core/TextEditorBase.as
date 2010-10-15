package jp.psyark.psycode.core {

	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import jp.psyark.psycode.core.history.HistoryEntry;
	import jp.psyark.psycode.core.history.HistoryManager;
	import jp.psyark.utils.StringComparator;
	

	/**
	* @private
	* TextEditorBaseクラスはTextEditUIクラスを継承し、
	* キーイベントのキャンセルなどテキストエディタの実装に必要な機能を提供します。
	*/
	public class TextEditorBase extends TextEditUI {
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
			Psymacs.instance.textChangeHook(this, event);
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
	}
}