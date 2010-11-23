<div id="node-<?php print $node->nid; ?>" class="node node-page<?php if (!$status) { print ' node-unpublished'; } ?>">
  <div class="node-body">
    <?php print $picture; ?>
    <div class="node-title clear-block">
    </div>
    
    <div class="content">
      <div class="captured-image">
	<a href="javascript:void(0);" title="Play" id="play-button"></a>
	<?php print $node->field_capture[0]['view'] ?>
      </div>
      <?php if ($submitted): ?>
      <div class="submitted"><p><?php print $submitted; ?></p></div>
      <?php endif; ?>
      <div class="forked-from"><p>Forked from: <?php print $node->field_forked_from[0]['view'] ?></p></div>
      <?php $raw_node = node_load($node->nid) ?>
      <div class="clear-block"></div>
      <pre class="las3r-code"><?php print check_plain($raw_node->body) ?></pre>
    </div>
    <div class="hr"><span></span></div>

    <div class="clear-block clear">
      <div class="meta">
	<?php if ($taxonomy): ?>
	<div class="terms"><?php print $terms ?></div>
	<?php endif;?>
      </div>

      <?php if ($links): ?>
      <div class="links"><?php print $links; ?></div>
      <?php endif; ?>
    </div>
  </div>
</div>
