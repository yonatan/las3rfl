<div id="node-<?php print $node->nid; ?>" class="node<?php if ($sticky) { print ' node-sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?>">
  <div class="node-top"><div class="top-right"><div class="top-middle"></div></div></div>
  <div class="node-body">
    <?php print $picture; ?>
    <div class="node-title clear-block">
      <h2 class="title"><a href="<?php print $node_url ?>" title="<?php print $title ?>"><?php print $title ?></a></h2>
      <?php if ($submitted): ?>
      <div class="submitted">
	<div class="left">
	  <p class="right">
	    <?php print $submitted; ?>
	  </p>
	</div>
      </div>
      <?php endif; ?>
    </div>

    <div class="content">
      <div class="captured-image"><?php print $node->field_capture[0]['view'] ?></div>
      <div class="forked-from">Forked from: <?php print $node->field_forked_from[0]['view'] ?></div>
      <?php $raw_node = node_load($node->nid) ?>
      <?php /* krumo($raw_node) */ ?>
      <div class="clear-block"></div>
      <?php /* print $content  */ ?>
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
