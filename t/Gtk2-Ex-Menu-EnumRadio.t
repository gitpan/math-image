#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Gtk2-Ex-WidgetBits.
#
# Gtk2-Ex-WidgetBits is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Gtk2-Ex-WidgetBits is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Gtk2-Ex-WidgetBits.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
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

plan tests => 19;

require App::MathImage::Gtk2::Ex::Menu::EnumRadio;

Glib::Type->register_enum ('My::Test1', 'foo', 'bar-ski', 'quux');

#------------------------------------------------------------------------------
# VERSION

my $want_version = 32;
{
  is ($App::MathImage::Gtk2::Ex::Menu::EnumRadio::VERSION,
      $want_version,
      'VERSION variable');
  is (App::MathImage::Gtk2::Ex::Menu::EnumRadio->VERSION,
      $want_version,
      'VERSION class method');

  ok (eval { App::MathImage::Gtk2::Ex::Menu::EnumRadio->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Gtk2::Ex::Menu::EnumRadio->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $menu = App::MathImage::Gtk2::Ex::Menu::EnumRadio->new;
  is ($menu->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $menu->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $menu->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}


#-----------------------------------------------------------------------------
# Scalar::Util::weaken

{
  my $menu = App::MathImage::Gtk2::Ex::Menu::EnumRadio->new;
  require Scalar::Util;
  Scalar::Util::weaken ($menu);
  is ($menu, undef, 'garbage collect when weakened');
}


#-----------------------------------------------------------------------------
# active-nick

{
  my $menu = App::MathImage::Gtk2::Ex::Menu::EnumRadio->new
    (enum_type => 'My::Test1');
  is ($menu->get('active-nick'), undef, 'get(active-nick) initial');
  is ($menu->get_active_nick, undef, 'get_active_nick() initial');

  my $saw_notify;
  $menu->signal_connect ('notify::active-nick' => sub {
                           $saw_notify++;
                         });

  $saw_notify = 0;
  $menu->set_active_nick ('quux');
  is ($saw_notify, 1, 'set_active_nick() notify');
  is ($menu->get('active-nick'), 'quux', 'set_active_nick() get()');
  is ($menu->get_active_nick, 'quux', 'set_active_nick() get_active_nick()');

  $saw_notify = 0;
  $menu->set ('active-nick', 'foo');
  is ($saw_notify, 1, 'set(active-nick) notify');
  is ($menu->get('active-nick'), 'foo', 'set_active_nick() get()');
  is ($menu->get_active_nick, 'foo', 'set_active_nick() get_active_nick()');

  $saw_notify = 0;
  $menu->set_active_nick ('foo');
  is ($saw_notify, 0, 'set_active_nick() unchanged no notify');
  is ($menu->get('active-nick'), 'foo', 'set_active_nick() get()');
  is ($menu->get_active_nick, 'foo', 'set_active_nick() get_active_nick()');
}

exit 0;
