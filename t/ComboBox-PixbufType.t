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
BEGIN {
  Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
  Gtk2->init_check
    or plan skip_all => 'due to no DISPLAY available';

  plan tests => 11;
}
require App::MathImage::Gtk2::Ex::ComboBox::PixbufType;


#------------------------------------------------------------------------------
# VERSION

my $want_version = 24;
{
  is ($App::MathImage::Gtk2::Ex::ComboBox::PixbufType::VERSION,
      $want_version,
      'VERSION variable');
  is (App::MathImage::Gtk2::Ex::ComboBox::PixbufType->VERSION,
      $want_version,
      'VERSION class method');

  ok (eval { App::MathImage::Gtk2::Ex::ComboBox::PixbufType->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Gtk2::Ex::ComboBox::PixbufType->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $combo = App::MathImage::Gtk2::Ex::ComboBox::PixbufType->new;
  is ($combo->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $combo->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $combo->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}


#-----------------------------------------------------------------------------
# notify

{
  my $combo = App::MathImage::Gtk2::Ex::ComboBox::PixbufType->new;
  my $saw_notify;
  $combo->signal_connect
    ('notify::active-type' => sub {
       $saw_notify = $combo->get('active-type');
     });
  $combo->set (active_type => 'jpeg');
  is ($combo->get('active-type'), 'jpeg', 'get() after set()');
  is ($saw_notify, 'jpeg', 'notify from set("active_type")');

#   $combo->set_active (0);
#   is ($combo->get('active-type'), 'png', 'get() after set_active()');
#   is ($saw_notify, 'png', 'notify from set_active()');
}


#-----------------------------------------------------------------------------
# Scalar::Util::weaken

{
  my $combo = App::MathImage::Gtk2::Ex::ComboBox::PixbufType->new;
  require Scalar::Util;
  Scalar::Util::weaken ($combo);
  is ($combo, undef,
      'garbage collect when weakened');
}

#-----------------------------------------------------------------------------
# Test::Weaken

# Test::Weaken 3 for "contents"
my $have_test_weaken = eval "use Test::Weaken 3; 1";
if (! $have_test_weaken) {
  diag "Test::Weaken 3 not available -- $@";
}

sub my_ignore {
  my ($ref) = @_;
  return ($ref == App::MathImage::Gtk2::Ex::ComboBox::PixbufType->DEFAULT_MODEL);
}

SKIP: {
  $have_test_weaken or skip 'due to Test::Weaken 3 not available', 1;

  require Test::Weaken::Gtk2;
  require Test::Weaken::ExtraBits;

  {
    my $leaks = Test::Weaken::leaks
      ({ constructor => sub {
           my $toplevel = Gtk2::Window->new ('toplevel');
           my $combo = App::MathImage::Gtk2::Ex::ComboBox::PixbufType->new;
           $toplevel->add ($combo);
           $toplevel->show_all;
           return $toplevel;
         },
         destructor => \&Test::Weaken::Gtk2::destructor_destroy,
         contents => \&Test::Weaken::Gtk2::contents_container,
         # ignore => \&my_ignore,
       });
    is ($leaks, undef, 'Test::Weaken deep garbage collection');
    if ($leaks) {
      eval { diag "Test-Weaken ", explain $leaks }; # explain new in 0.82

      my $unfreed = $leaks->unfreed_proberefs;
      say "unfreed isweak ",
        (Scalar::Util::isweak ($unfreed->[0]) ? "yes" : "no");
      foreach my $proberef (@$unfreed) {
        diag "  unfreed $proberef";
      }
      foreach my $proberef (@$unfreed) {
        diag "  search $proberef";
        MyTestHelpers::findrefs($proberef);
      }
    }
  }
}

exit 0;
