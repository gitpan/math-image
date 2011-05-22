#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.008;
use strict;
use warnings;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

use Gtk2;
Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
Gtk2->init_check
  or plan skip_all => 'due to no DISPLAY available';
MyTestHelpers::glib_gtk_versions();

plan tests => 16;

require App::MathImage::Gtk2::Ex::ToolItem::CheckButton;


#------------------------------------------------------------------------------
# VERSION

my $want_version = 58;
{
  is ($App::MathImage::Gtk2::Ex::ToolItem::CheckButton::VERSION,
      $want_version,
      'VERSION variable');
  is (App::MathImage::Gtk2::Ex::ToolItem::CheckButton->VERSION,
      $want_version,
      'VERSION class method');

  ok (eval { App::MathImage::Gtk2::Ex::ToolItem::CheckButton->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Gtk2::Ex::ToolItem::CheckButton->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $main = App::MathImage::Gtk2::Ex::ToolItem::CheckButton->new;
  is ($main->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $main->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $main->VERSION($check_version); 1 },
      "VERSION object check $check_version");

  $main->destroy;
}


#-----------------------------------------------------------------------------
# "tooltip-text" propagate

SKIP: {
  my $tcb = App::MathImage::Gtk2::Ex::ToolItem::CheckButton->new;
  $tcb->find_property('tooltip-text')
    or skip "due to no tooltip-text property", 1;

  my $menuitem = $tcb->retrieve_proxy_menu_item;
  my $str = 'Blah blah tooltip text.';
  $tcb->set (tooltip_text => $str);
  is ($menuitem->get ('tooltip-text'), $str, 'menuitem tooltip-text');
}

#-----------------------------------------------------------------------------
# initial menuitem "sensitive" property

{
  my $tcb = App::MathImage::Gtk2::Ex::ToolItem::CheckButton->new;
  my $menuitem = $tcb->retrieve_proxy_menu_item;
  is (!! $menuitem->get('sensitive'), !! 1, 'menuitem sensitive initial 0');
}
{
  my $tcb = App::MathImage::Gtk2::Ex::ToolItem::CheckButton->new
    (sensitive => 0);
  my $menuitem = $tcb->retrieve_proxy_menu_item;
  is (!! $menuitem->get('sensitive'), !! 0, 'menuitem sensitive initial 0');
}

#-----------------------------------------------------------------------------
# propagate "sensitive" property

{
  my $tcb = App::MathImage::Gtk2::Ex::ToolItem::CheckButton->new;
  my $menuitem = $tcb->retrieve_proxy_menu_item;
  $tcb->set (sensitive => 0);
  is (!! $menuitem->get('sensitive'), !! 0, 'menuitem sensitive propagate 0');
  $tcb->set (sensitive => 1);
  is (!! $menuitem->get('sensitive'), !! 1, 'menuitem sensitive propagate 1');
}

#-----------------------------------------------------------------------------
# Scalar::Util::weaken

{
  my $tcb = App::MathImage::Gtk2::Ex::ToolItem::CheckButton->new;
  my $checkbutton = $tcb->get_child;
  require Scalar::Util;
  Scalar::Util::weaken ($tcb);
  Scalar::Util::weaken ($checkbutton);
  is ($tcb, undef, 'ToolItem garbage collect when weakened');
  is ($checkbutton, undef, 'CheckButton garbage collect when weakened');
}

{
  my $tcb = App::MathImage::Gtk2::Ex::ToolItem::CheckButton->new;
  my $menuitem = $tcb->retrieve_proxy_menu_item;
  require Scalar::Util;
  Scalar::Util::weaken ($tcb);
  Scalar::Util::weaken ($menuitem);
  is ($tcb, undef, 'ToolItem garbage collect when weakened');
  is ($menuitem, undef, 'MenuItem garbage collect when weakened');
}

exit 0;
