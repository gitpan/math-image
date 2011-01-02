#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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
MyTestHelpers::glib_gtk_versions();

plan tests => 14;

require App::MathImage::Gtk2::Ex::ToolItem::ComboEnum;
diag "Buildable: ",App::MathImage::Gtk2::Ex::ToolItem::ComboEnum->isa('Gtk2::Buildable')||0;

Glib::Type->register_enum ('My::Test1', 'foo', 'bar-ski', 'quux');

#------------------------------------------------------------------------------
# VERSION

my $want_version = 38;
{
  is ($App::MathImage::Gtk2::Ex::ToolItem::ComboEnum::VERSION,
      $want_version,
      'VERSION variable');
  is (App::MathImage::Gtk2::Ex::ToolItem::ComboEnum->VERSION,
      $want_version,
      'VERSION class method');

  ok (eval { App::MathImage::Gtk2::Ex::ToolItem::ComboEnum->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Gtk2::Ex::ToolItem::ComboEnum->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::ComboEnum->new;
  is ($toolitem->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $toolitem->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $toolitem->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}


#-----------------------------------------------------------------------------
# Scalar::Util::weaken

{
  my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::ComboEnum->new;
  require Scalar::Util;
  Scalar::Util::weaken ($toolitem);
  is ($toolitem, undef, 'garbage collect when weakened');
}


#-----------------------------------------------------------------------------
# active-nick

{
  my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::ComboEnum->new
    (enum_type => 'My::Test1');
  is ($toolitem->get('active-nick'), undef, 'get(active-nick) initial');

  my $saw_notify;
  $toolitem->signal_connect ('notify::active-nick' => sub {
                               $saw_notify++;
                             });

  $saw_notify = 0;
  $toolitem->set (active_nick => 'quux');
  is ($saw_notify, 1, 'set_active_nick() notify');
  is ($toolitem->get('active-nick'), 'quux', 'set(active-nick) get()');

  $saw_notify = 0;
  $toolitem->set ('active-nick', 'foo');
  is ($saw_notify, 1, 'set(active-nick) notify');
  is ($toolitem->get('active-nick'), 'foo', 'set(active-nick) get()');

  $saw_notify = 0;
  $toolitem->set (active_nick => 'foo');
  is ($toolitem->get('active-nick'), 'foo', 'set(active-nick) get()');
}

exit 0;
