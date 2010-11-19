<?php
$module_path = drupal_get_path('module', 'las3rfl_code');
drupal_add_js('var modulePath = "'. base_path() . $module_path .'/";', 'inline');
drupal_add_js($module_path .'/swfobject/swfobject.js');
drupal_add_js($module_path .'/nomacs.js');
drupal_add_css($module_path .'/nomacs.css');
?>
<table cellspacing=0 cellpadding=0>
  <tr>
    <td id="editor">
      <div id="editorSWF"></div>
    </td>
    <td id="evaluator">
      <div id="evaluatorSWF"></div>

      <!-- fake content-bar for aesthetic purposes -->
      <div class="content-bar">
	<div class="left">
	  <ul class="tabs primary">
	    <li><a id="resetBtn" href="#">Reset eval SWF</a></li>
	    <li><a href="#">Fullscreen</a></li>
	  </ul>
	</div>
      </div>
      
      <p>In the event of a crash; reload the page and press Alt-R in the editor to recover the last version.</p>
    </td>
  </tr>
</table>
