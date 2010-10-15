package jp.psyark.psycode {

	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.FileReference;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import jp.psyark.psycode.core.history.HistoryManager;
	import jp.psyark.psycode.core.history.HistoryEntry;
	import jp.psyark.utils.StringComparator;
	import jp.psyark.psycode.core.TextEditorBase;

	/**
	* TextEditorクラス
	*/
	public class TextEditor extends TextEditorBase {
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
	}
}