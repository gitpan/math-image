#!/usr/bin/perl -w

# Copyright 2007, 2008, 2009, 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with MathImage.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use Test::More;

BEGIN {
  use lib 't';
  use MyTestHelpers;
  MyTestHelpers::nowarnings();
}

# uncomment this to run the ### lines
#use Smart::Comments;

Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
Gtk2->init_check
  or plan skip_all => 'due to no DISPLAY available';

plan tests => 14;

{
  package TestWidgetOne;
  use Gtk2;
  our @ISA;
  use Glib::Object::Subclass
    'Gtk2::CheckMenuItem',
      properties => [Glib::ParamSpec->string
                     ('testprop',
                      'testprop',
                      'Blurb ...',
                      'testprop default',
                      Glib::G_PARAM_READWRITE)];
  use App::MathImage::Gtk2::Ex::MenuItem::Subclass;
  unshift @ISA, 'App::MathImage::Gtk2::Ex::MenuItem::Subclass';
}

{
  diag join(' ',@TestWidgetOne::ISA);
  diag "subclass ", App::MathImage::Gtk2::Ex::MenuItem::Subclass->can('new');
  diag "gobject  ",\&Glib::Object::new;
  diag "testwidg ",TestWidgetOne->can('new');

  {
    my $w = TestWidgetOne->new ();
    isa_ok ($w, 'TestWidgetOne','new(undef)');
    is ($w->get ('testprop'), 'testprop default',
        'new() has testprop property');
    $w->destroy;
  }
  {
    my $w = TestWidgetOne->new ('Foo');
    isa_ok ($w, 'TestWidgetOne','new(str)');
    is ($w->get ('testprop'), 'testprop default',
        'new(str) has testprop property');
    $w->destroy;
  }

  {
    my $w = TestWidgetOne->new_with_label ();
    isa_ok ($w, 'TestWidgetOne',
            'new_with_label()');
    is ($w->get ('testprop'), 'testprop default',
        'new_with_label() has testprop property');
    $w->destroy;
  }
  {
    my $w = TestWidgetOne->new_with_label ('Foo');
    isa_ok ($w, 'TestWidgetOne',
            'new_with_label(str)');
    is ($w->get ('testprop'), 'testprop default',
        'new_with_label(str) has testprop property');
    $w->destroy;
  }

  {
    my $w = TestWidgetOne->new_with_mnemonic ();
    isa_ok ($w, 'TestWidgetOne',
            'new_with_mnemonic()');
    is ($w->get ('testprop'), 'testprop default',
        'new_with_mnemonic() has testprop property');
    $w->destroy;
  }
  {
    my $w = TestWidgetOne->new_with_mnemonic ('Foo');
    isa_ok ($w, 'TestWidgetOne',
            'new_with_mnemonic(str)');
    is ($w->get ('testprop'), 'testprop default',
        'new_with_mnemonic(str) has testprop property');
    $w->destroy;
  }
}

#------------------------------------------------------------------------------
# new_with_label()

foreach my $elem ([ 'no args', [] ],
                  [ 'arg string', ['hello'] ]) {
  my ($name, $args) = @$elem;
  ### $args
  my $i1 = Gtk2::MenuItem->new_with_label (@$args);
  my $i2 = TestWidgetOne->new_with_label (@$args);
  is (!!$i1->get_child, !!$i1->get_child, "new_with_label() $name");
}

exit 0;
