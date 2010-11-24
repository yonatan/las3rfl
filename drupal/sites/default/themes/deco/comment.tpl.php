<div class="comment<?php if (isset($comment->status) && $comment->status == COMMENT_NOT_PUBLISHED) print ' comment-unpublished'; print ($zebra ? ' comment-'.$zebra : ''); ?>">
  <?php if ($new != '') { ?><span class="new"><?php print $new; ?></span><?php } ?>

  <div class="comment-top">
    <?php print $picture; ?>
    <?php if (variable_get('comment_subject_field_'. $node->type, 1)): ?>
    <h3 class="title"><?php print $title; ?></h3>
    <?php endif; ?>
    <?php if ($submitted): ?>
    <span class="submitted"><?php print $submitted; ?></span>
    <?php endif; ?>
  </div>
  <div class="content"><?php print $content; ?></div>
  <?php if ($signature): ?>
  <div class="signature">
    <?php print $signature ?>
  </div>
  <?php endif; ?>
  <div class="hr"><span></span></div>
  <div class="links"><?php print $links; ?></div>
</div>
