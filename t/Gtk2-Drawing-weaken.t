#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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

use App::MathImage::Gtk2::Generator;
use Test::Weaken::Gtk2 39; # v.39 for ignore_default_root_window()

use Gtk2;
Gtk2->init_check
  or plan skip_all => 'due to no DISPLAY available';
MyTestHelpers::glib_gtk_versions();

# Test::Weaken 3 for "contents"
eval "use Test::Weaken 3; 1"
  or plan skip_all => "Test::Weaken 3 not available -- $@";

eval { require Test::Weaken::ExtraBits; 1 }
  or plan skip_all => "due to Test::Weaken::ExtraBits not available -- $@";

plan tests => 1;

#------------------------------------------------------------------------------

{
  require App::MathImage::Gtk2::Drawing;
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         return App::MathImage::Gtk2::Drawing->new;
       },
       contents => \&Test::Weaken::Gtk2::contents_container,
       destructor => sub {
         my ($drawing) = @_;
         MyTestHelpers::diag ('gen "widget" isweak ',
                              $drawing->{'gen_object'}
                              && Scalar::Util::isweak($drawing->{'gen_object'}->{'widget'}));
       },
       ignore => sub {
         my ($ref) = @_;
         return (Test::Weaken::Gtk2::ignore_default_root_window($ref)
                 || $ref == App::MathImage::Generator::default_options->{'path_parameters'});
       },
     });
  is ($leaks, undef,
      'deep garbage collection - gen on Drawing and root window');
  MyTestHelpers::test_weaken_show_leaks($leaks);
}


exit 0;
