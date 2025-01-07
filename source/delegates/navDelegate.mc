import Toybox.WatchUi;

class NavDelegate extends WatchUi.BehaviorDelegate {
  var view;

  function initialize(_view) {
    BehaviorDelegate.initialize();

    view = _view;
  }

  function onNextPage() {
    if (view.verticalScrollBar != null) {
      view.verticalScrollBar.position++;
      if (view.verticalScrollBar.position >= view.verticalScrollBar.length) {
        view.verticalScrollBar.position = 0;
      }
      view.requestUpdate();
      return true;
    }
    return false;
  }

  function onPreviousPage() {
    if (view.verticalScrollBar != null) {
      view.verticalScrollBar.position--;
      if (view.verticalScrollBar.position < 0) {
        view.verticalScrollBar.position = view.verticalScrollBar.length - 1;
      }
      view.requestUpdate();
      return true;
    }
    return false;
  }

  function onSelect() {
    if (getApp().loading) {
      return false;
    }
    if (view.horizontalScrollBar != null) {
      view.horizontalScrollBar.position++;
      if (
        view.horizontalScrollBar.position >= view.horizontalScrollBar.length
      ) {
        view.horizontalScrollBar.position = 0;
      }
      view.updateCurrentStop();
      view.requestUpdate();
      return true;
    }
    return false;
  }
}
