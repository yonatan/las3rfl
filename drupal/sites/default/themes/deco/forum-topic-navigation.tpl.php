<?php if ($prev || $next): ?>
  <div class="content-bar"><div class="left"><div class="forum-topic-navigation clear-block">
    <?php if ($prev): ?>
      <a href="<?php print $prev_url; ?>" class="topic-previous" title="<?php print t('Go to previous forum topic') ?>">‹ <?php print $prev_title ?></a>
    <?php endif; ?>
    <?php if ($next): ?>
      <a href="<?php print $next_url; ?>" class="topic-next" title="<?php print t('Go to next forum topic') ?>"><?php print $next_title ?> ›</a>
    <?php endif; ?>
  </div></div></div>
<?php endif; ?>
