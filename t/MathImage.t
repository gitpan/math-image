#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
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
use Test::More tests => 36;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

# uncomment this to run the ### lines
#use Smart::Comments;

require App::MathImage;
require POSIX;
POSIX::setlocale(POSIX::LC_ALL(), 'C'); # no message translations


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 32;
  is ($App::MathImage::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}

#------------------------------------------------------------------------------

foreach my $elem
  (
   [ ['--text', '--vogel'] ],

   [ ['--version'] ],
   [ ['--help'] ],
   [ ['--verbose', '--version'] ],

   [ ['--text'] ],
   [ ['--text', '--scale=5'] ],
   [ ['--text', '--size=10'] ],
   [ ['--text', '--size=10x20'] ],
   [ ['--text', '--sacks'] ],
   # [ ['--text', '--random'] ],  # could need all modules

   [ ['--text-numbers'] ],
   [ ['--text-list'] ],
   [ ['--xpm'],           modules => ['Image::Xpm'] ],
   [ ['--png-gd'],        modules => ['Image::Base::GD'] ],
   [ ['--png-gtk']        ], # always have Image::Base::Gtk2::Gdk::Pixbuf
   [ ['--png-pngwriter'], modules => ['Image::Base::PNGwriter'] ],
   [ ['--png'],           modules => ['Image::Base::GD'] ],

   # [ ['--prima'],         module => 'Prima' ],
  ) {
 SKIP: {
    my ($argv, %options) = @$elem;
    foreach my $module (@{$options{'modules'}}) {
      ### load module: $module
      if (! eval "require $module") {
        skip "due to $module not available: $@", 2;
      }
    }
    local @ARGV = @$argv;
    diag "command_line() ",join(' ',@ARGV);
    local *STDOUT;
    require File::Spec;
    my $devnull = File::Spec->devnull;
    open STDOUT, '>', $devnull
      or die "Cannot open $devnull";

    # class method
    is (App::MathImage->command_line,
        0,
        "command ".join(' ',@$argv));

    # object method
    @ARGV = @$argv;
    my $mi = App::MathImage->new;
    is ($mi->command_line,
        0,
        "command ".join(' ',@$argv));
  }
  }

exit 0;
