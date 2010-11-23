<div class="node node-page<?php if (!$status) { print ' node-unpublished'; } ?>">
  <div class="node-body">
    <?php $raw_node = node_load($node->nid) ?>
    <div class="node-title clear-block">
    </div>
    
    <div class="content">
      <div class="captured-image">
	<a href="javascript:void(0);" title="Play" id="play-button"></a>
	<?php print $node->field_capture[0]['view'] ?>
      </div>
      <div class="submitted"><p>Posted by:<br/><?php print $submitted; ?></p></div>
      <?php if ($node->field_forked_from[0]['nid']): ?>
      <div class="forked-from"><p>Forked from:<br/><?php print $node->field_forked_from[0]['view'] ?></p></div>
      <?php endif ?>
      <div class="clear-block"></div>
      <div class="code-container">
	<pre class="las3r-code"><?php print check_plain($raw_node->body) ?></pre>
	<a class="raw-code-link" href="/node/<?php print $node->nid?>/raw">View raw code</a>
      </div>
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
