// Card — base class for list-item renderers (mirrors Screen's shape at the
// "how it exposes state" level, NOT the DOM-ownership level).
//
// Cards do not own a live DOM node and do not attach their own listeners —
// render() returns an HTML string that the hosting screen folds into a
// bigger innerHTML build (same idiom as Screen.renderList / renderColumn
// throughout the roster screens). Click handling stays on the screen's
// single delegated listener, dispatching on data-* attributes the card's
// HTML sets. This deliberately avoids the per-item-listener leak a
// mount/unmount component model would reintroduce under ScreenManager's
// full-innerHTML-wipe navigation (see screen-manager.js `show()`).
class Card {
  // data: the item being rendered (e.g. a player row).
  // context: shared rendering context from the host screen — whatever the
  // subclass needs (e.g. { columns, coachedTeamIds }).
  constructor(data, context = {}) {
    this.data = data;
    this.context = context;
  }

  render() {
    throw new Error('Card subclasses must implement render()');
  }
}
