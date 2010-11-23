<div id="node-<?php print $node->nid; ?>" class="node code-teaser<?php if ($sticky) { print ' node-sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?>">
  <div class="node-body">

    <div class="content">
      <div class="captured-image"><?php print $node->field_capture[0]['view'] ?></div>
      <div class="node-title clear-block">
	<h3 class="title"><a href="<?php print $node_url ?>" title="<?php print $title ?>"><?php print truncate_utf8($title, 35, FALSE, TRUE) ?></a></h3>
      </div>
      <?php print l($node->name, 'user/'. $node->uid); ?>
      <div class="clear-block"></div>
    </div>

    <div class="clear-block clear">
      <div class="meta">
	<?php if ($taxonomy): ?>
	<div class="terms"><?php print $terms ?></div>
	<?php endif;?>
      </div>

    </div>
  </div>
</div>
