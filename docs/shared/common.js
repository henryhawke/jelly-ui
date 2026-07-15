/*
 * Shared behavior for both docs pages (the showcase and the API
 * reference): the theme toggle
 */

import { jellyIcon }    from '../../package.js';
import { setThemeMode } from '../../package.js';
import { getThemeMode } from '../../package.js';
import { escapeHTML }   from '../../package.js';

export { escapeHTML };

// Render backtick-delimited identifiers as inline code after escaping the
// complete string, so documentation copy can be expressive without allowing
// arbitrary HTML from the data file.
export function formatInlineCode (text) {
  return escapeHTML(text).replace(/`([^`]+)`/g, '<code>$1</code>');
}

// The theme cycles auto → light → dark → auto. "auto" carries no forced mode,
// so the page follows the OS / browser preference (and live-updates when it
// changes); light / dark are explicit overrides.
const ORDER  = ['auto', 'light', 'dark'];
const ICON   = { auto: 'theme-auto', light: 'weather-sunny', dark: 'weather-moon' };
const NAME   = { auto: 'system', light: 'light', dark: 'dark' };

/*
 * Wire the theme cycle button (Fluent icons): it shows the current mode's icon
 * and cycles auto → light → dark on click, remembering an explicit choice and
 * clearing it to follow the system again on "auto". (The pre-paint boot script
 * in each page's <head> reads the same localStorage key, so there is no flash.)
 */
export function wireThemeToggle (button) {
  if (!button) {
    return;
  }

  const sync = () => {
    const mode = getThemeMode();

    button.innerHTML = jellyIcon(ICON[mode], { size: 17 });
    button.setAttribute('label', `Theme: ${NAME[mode]}. Click to change.`);
  };

  button.addEventListener('click', () => {
    const next = ORDER[(ORDER.indexOf(getThemeMode()) + 1) % ORDER.length];

    setThemeMode(next);

    if (next === 'auto') {
      localStorage.removeItem('jelly-docs-theme');
    } else {
      localStorage.setItem('jelly-docs-theme', next);
    }

    sync();
  });

  // The OS can flip the resolved mode while in auto; keep the icon in step
  window.addEventListener('jelly-theme-change', sync);

  sync();
}
