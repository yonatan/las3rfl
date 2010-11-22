<div id="node-<?php print $node->nid; ?>" class="node<?php if ($sticky && $page == 0) { print ' node-sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?><?php if ($page != 0) { print ' node-page'; } ?>">
	<?php if ($page == 0): ?>
	<div class="node-top"><div class="top-right"><div class="top-middle"></div></div></div>
	<?php endif; ?>
	<div class="node-body">
	<?php print $picture; ?>
	<div class="node-title clear-block">
	<?php if ($page == 0): ?>
	<h2 class="title"><a href="<?php print $node_url ?>" title="<?php print $title ?>"><?php print $title ?></a></h2>
	<?php endif; ?>
	  <?php if ($submitted): ?>
	    <div class="submitted">
		<?php if ($page == 0): ?>
				<div class="left">
		<?php endif; ?>
				<p<?php print ($page == 0) ? ' class="right"' : '' ?>>
				<?php print $submitted; ?>
				</p>
		<?php if ($page == 0): ?>
				</div>
		<?php endif; ?>
			</div>
	  <?php endif; ?>
	</div>
	
  <div class="content">
    <div class="captured-image"><?php print $node->field_capture[0]['view'] ?></div>
    <?php $raw_node = node_load($node->nid) ?>
    <div class="clear-block"></div>
    <pre class="las3r-code"><?php print check_plain($raw_node->body) ?></pre>
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
