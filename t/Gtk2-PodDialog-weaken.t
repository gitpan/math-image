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

use App::MathImage::Gtk2::PodDialog;
use Test::Weaken::Gtk2;
use Test::Weaken::ExtraBits; # in 't' dir

use Gtk2;
Gtk2->init_check
  or plan skip_all => 'due to no DISPLAY available';

# Test::Weaken 3 for "contents"
eval "use Test::Weaken 3; 1"
  or plan skip_all => "Test::Weaken 3 not available -- $@";

plan tests => 1;

# Somehow a GtkFileChooserDefault stays alive in gtk 2.20.  Is it meant to,
# to keep global settings?  In any case ignore for now.
sub my_ignore {
  my ($ref) = @_;
  return (ref($ref) =~ /::GtkFileChooserDefault$/);
}

{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         my $dialog = App::MathImage::Gtk2::PodDialog->new;
         $dialog->show;
         MyTestHelpers::main_iterations();
         return $dialog;
       },
       destructor => \&Test::Weaken::Gtk2::destructor_destroy,
       contents => \&Test::Weaken::Gtk2::contents_container,
       ignore => \&my_ignore,
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

exit 0;
