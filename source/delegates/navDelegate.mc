import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Communications;
import Toybox.Lang;

class NavDelegate extends WatchUi.BehaviorDelegate {
  var view;
  var menuPressed = false;

  function initialize(_view) {
    BehaviorDelegate.initialize();

    view = _view;
  }

  function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Boolean {
    if (keyEvent.getKey() == WatchUi.KEY_MENU) {
      menuPressed = true;
      new Timer.Timer().start(method(:onTimer), 1000, false);
    }
    return false;
  }

  function onKeyReleased(keyEvent as WatchUi.KeyEvent) as Boolean {
    if (keyEvent.getKey() == WatchUi.KEY_MENU) {
      menuPressed = false;
    }
    return false;
  }

  function onTimer() as Void {
    if(menuPressed) {
        var app = getApp();
        var stop = (app.stops != null && app.currentStop != null) ? app.stops[app.currentStop] : null;
        if(stop == null) {
            return;
        }
        var settingsMenu = new WatchUi.Menu();
        settingsMenu.setTitle(stop.name);
        settingsMenu.addItem(stop.favorite ? Rez.Strings.RemoveFromFavorites : Rez.Strings.AddToFavorites, :favorite);
        settingsMenu.addItem(Rez.Strings.SetAsGlanceStop, :glance);
        var delegate = new SettingsDelegate();
        WatchUi.pushView(
          settingsMenu,
            delegate,
            WatchUi.SLIDE_IMMEDIATE
        );
        menuPressed = false;
    }
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
    if (view.horizontalScrollBar != null) {
      Communications.cancelAllRequests();
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
