#include "app.h"

#include <chrono>
#include <thread>

#include "../data/api.h"

#define COLOR_HIGHLIGHT 1
#define COLOR_MODAL_BORDER 2

App *App::instance = 0;

App *App::getInstance() {
  if (instance == 0) {
    instance = new App();
  }
  return instance;
}

App::~App() { endwin(); }

App::App() {}

int App::getKeyPress() {}

void App::pushKey(int key) {}

void App::drawMainWinList() {}
