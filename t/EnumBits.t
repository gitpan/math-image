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

use 5.008;
use strict;
use warnings;
use Test::More tests => 13;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

require App::MathImage::Glib::Ex::EnumBits;

{
  my $want_version = 15;
  is ($App::MathImage::Glib::Ex::EnumBits::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::Glib::Ex::EnumBits->VERSION,  $want_version, 'VERSION class method');
  ok (eval { App::MathImage::Glib::Ex::EnumBits->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Glib::Ex::EnumBits->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}

require Gtk2;
Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
MyTestHelpers::glib_gtk_versions();

#-----------------------------------------------------------------------------

foreach my $elem (['foo', 'Foo'],
                  ['foo-bar', 'Foo Bar'],
                  ['foo_bar', 'Foo Bar'],
                  ['foo1', 'Foo 1'],
                  ['foo1bar', 'Foo 1 Bar'],
                  ['foo12bar', 'Foo 12 Bar'],
                  ['foo123bar4', 'Foo 123 Bar 4'],
                  ['FooBar', 'Foo Bar'],
                  ['Foo2Bar', 'Foo 2 Bar'],
                 ) {
  my ($nick, $want) = @$elem;
  my $got = App::MathImage::Glib::Ex::EnumBits::to_text_default(undef,$nick);
  is ($got, $want, "to_text_default $nick");
}

exit 0;
