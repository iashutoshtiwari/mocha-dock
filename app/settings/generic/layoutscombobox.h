/*
    SPDX-FileCopyrightText: 2021 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef LAYOUTSCOMBOBOX_H
#define LAYOUTSCOMBOBOX_H

//local
#include "../../data/layouticondata.h"

//Qt
#include <QComboBox>
#include <QPaintEvent>

namespace Mocha {
namespace Settings {

class LayoutsComboBox : public QComboBox
{
  Q_OBJECT
public:
  LayoutsComboBox(QWidget *parent = nullptr);

  Mocha::Data::LayoutIcon layoutIcon() const;
  void setLayoutIcon(const Mocha::Data::LayoutIcon &icon);

protected:
  void paintEvent(QPaintEvent *event) override;

private:
  Mocha::Data::LayoutIcon m_layoutIcon;

};

}
}

#endif
