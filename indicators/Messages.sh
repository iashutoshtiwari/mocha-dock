#! /usr/bin/env bash

$XGETTEXT `find default -name \*.js -o -name \*.qml -o -name \*.cpp` -o $podir/mocha_indicator_org.kde.mocha.default.pot
$XGETTEXT `find org.kde.mocha.plasma -name \*.js -o -name \*.qml -o -name \*.cpp` -o $podir/mocha_indicator_org.kde.mocha.plasma.pot
$XGETTEXT `find org.kde.mocha.plasmatabstyle -name \*.js -o -name \*.qml -o -name \*.cpp` -o $podir/mocha_indicator_org.kde.mocha.plasmatabstyle.pot 
