<?php
   $module_path = drupal_get_path('module', 'las3rfl_code');
   // Settings to be passed to js
   $settings = array('modulePath' => $module_path,
'swfDomain' => variable_get('swf_domain', NULL),
'nid' => $node->nid,
);

drupal_add_js($settings, 'setting');
drupal_add_js($module_path .'/swfobject/swfobject.js');
drupal_add_js($module_path .'/viewer.js');
?>
<div class="node node-page<?php if (!$status) { print ' node-unpublished'; } ?>">
  <div class="node-body">
    <?php $raw_node = node_load($node->nid) ?>
    <div class="node-title clear-block">
    </div>
    
    <div class="content">
      <div class="captured-image">
	<a href="javascript:void(0);" title="Play" id="play-button"></a>
	<?php print $node->field_capture[0]['view'] ?>
	<div id="viewer-swf"></div>
      </div>
      <div class="submitted"><p>Posted by:<br/><?php print $submitted; ?></p></div>
      <?php if ($node->field_forked_from[0]['nid']): ?>
      <div class="forked-from"><p>Forked from:<br/><?php print $node->field_forked_from[0]['view'] ?></p></div>
      <?php endif ?>
      <div class="clear-block"></div>

      <!-- AddThis Button BEGIN -->
      <div class="addthis_toolbox addthis_default_style ">
	<a href="http://www.addthis.com/bookmark.php?v=250&amp;username=xa-4cee9b6d3fdaad26" class="addthis_button_compact">Share</a>
	<span class="addthis_separator">|</span>
	<a class="addthis_button_preferred_1"></a>
	<a class="addthis_button_preferred_2"></a>
	<a class="addthis_button_preferred_3"></a>
	<a class="addthis_button_preferred_4"></a>
      </div>
      <script type="text/javascript">
	var addthis_config = { ui_click: true, ui_hover_direction: -1 };
      </script>
      <script type="text/javascript" src="http://s7.addthis.com/js/250/addthis_widget.js#username=xa-4cee9b6d3fdaad26"></script>
      <!-- AddThis Button END -->

      <?php if ($links): ?>
      <div class="links"><?php print $links; ?></div>
      <?php endif; ?>
      <div class="clear-block"></div>

      <div class="code-container">
	<pre class="las3r-code"><?php print check_plain($raw_node->body) ?></pre>
	<?php print l('View raw code', 
	              'node/'. $node->nid .'/raw',
	              array('attributes' => array('class' => 'raw-code-link'))) ?>
      </div>
    </div>
    <div class="hr"><span></span></div>

    <div class="clear-block clear">
      <div class="meta">
	<?php if ($taxonomy): ?>
	<div class="terms"><?php print $terms ?></div>
	<?php endif;?>
      </div>

    </div>
  </div>
</div>
