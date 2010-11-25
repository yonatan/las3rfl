<?php
$module_path = drupal_get_path('module', 'las3rfl_code');
// parameters to be passed to editor swf.
global $user;
$params = array('nid' => ($node ? $node->nid : 0),
		'fork' => $fork,
		'uid' => $user->uid,
		'swfDomain' => variable_get('swf_domain', NULL),
		);
// Settings to be passed to js
$settings = array('modulePath' => $module_path,
		  'editorVars' => $params,
		  'siteDomain' => variable_get('site_domain', NULL),
		  );

drupal_add_js($settings, 'setting');
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
	      <a id="resetBtn" href="javascript:void(0);">Reset evaluator</a>
	    </li>
	    <li id="fullscreen">
	      <a id="fullscreenBtn" href="javascript:void(0);">Fullscreen</a>
	    </li>
	  </ul>
	</div>
      </div>
      <p>In the event of a crash; reload the page and press Ctrl-Alt-R in the editor to recover the last version. Ctrl-Enter to run, Ctrl-H for help.</p>
    </td>
  </tr>
</table>
