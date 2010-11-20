<?php
$module_path = drupal_get_path('module', 'las3rfl_code');
$js =  'var modulePath = "'. base_path() . $module_path .'/";';
$js .= 'var nid = '. ($node ? $node->nid : 0) .';';
$js .= 'var fork = '. ($fork ? 'true' : 'false')  .';';
drupal_add_js($js, 'inline');
drupal_add_js($module_path .'/swfobject/swfobject.js');
drupal_add_js($module_path .'/nomacs.js');
drupal_add_css($module_path .'/nomacs.css');
?>
<table id="editor-container" cellspacing=0 cellpadding=0>
  <tr>
    <td id="editor">
      <div id="editorSWF"></div>
    </td>
    <td id="evaluator">
      <div id="evaluator-container">
	<div id="evaluatorSWF"></div>
      </div>

      <!-- fake content-bar for aesthetic purposes -->
      <div class="content-bar">
	<div class="left">
	  <ul class="tabs primary">
	    <li>
	      <a id="resetBtn" href="#">Reset evaluator</a>
	    </li>
	    <li id="fullscreen">
	      <a id="fullscreenBtn" href="#">Fullscreen</a>
	    </li>
	  </ul>
	</div>
      </div>
  <p>In the event of a crash; reload the page and press Alt-R in the editor to recover the last version. Ctrl-Enter to run, Ctrl-H for help.</p>
    </td>
  </tr>
</table>
