#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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

BEGIN { require 5 }
use strict;
use Test;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

my $test_count = 100;
plan tests => $test_count;

{
  my $have_x11_protocol = eval { require X11::Protocol; 1 };
  if (! $have_x11_protocol) {
    MyTestHelpers::diag ('X11::Protocol not available -- ',$@);
    foreach (1 .. $test_count) {
      skip ('X11::Protocol not available', 1, 1);
    }
    exit 0;
  }
  MyTestHelpers::diag ("X11::Protocol version ", X11::Protocol->VERSION);
}
{
  my $have_x11_protocol_other = eval { require X11::Protocol::Other; 1 };
  if (! $have_x11_protocol_other) {
    MyTestHelpers::diag ('X11::Protocol::Other not available -- ',$@);
    foreach (1 .. $test_count) {
      skip ('X11::Protocol::Other not available', 1, 1);
    }
    exit 0;
  }
  MyTestHelpers::diag ("X11::Protocol::Other version ", X11::Protocol::Other->VERSION);
}

my $display = $ENV{'DISPLAY'};
if (! defined $display) {
  foreach (1 .. $test_count) {
    skip ('No DISPLAY set', 1, 1);
  }
  exit 0;
}

# pass display arg so as not to get a "guess" warning
my $X;
if (! eval { $X = X11::Protocol->new ($display); }) {
  MyTestHelpers::diag ('Cannot connect to X server -- ',$@);
  foreach (1 .. $test_count) {
    skip ('Cannot connect to X server', 1, 1);
  }
  exit 0;
}
$X->QueryPointer($X->{'root'});  # sync

require App::MathImage::X11::Protocol::XSetRoot;

#------------------------------------------------------------------------------
# VERSION

my $want_version = 49;
ok ($App::MathImage::X11::Protocol::XSetRoot::VERSION,
    $want_version,
    'VERSION variable');
ok (App::MathImage::X11::Protocol::XSetRoot->VERSION,
    $want_version,
    'VERSION class method');

ok (eval { App::MathImage::X11::Protocol::XSetRoot->VERSION($want_version); 1 },
    1,
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::X11::Protocol::XSetRoot->VERSION($check_version); 1 },
    1,
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# _rgbstr_to_card16()

foreach my $elem ([ 'bogosity' ],
                  [ '#' ],
                  [ '#1' ],
                  [ '#12' ],

                  [ '#def', 0xDDDD, 0xEEEE, 0xFFFF ],

                  [ '#1234' ],
                  [ '#12345' ],

                  [ '#123456', 0x1212, 0x3434, 0x5656 ],
                  [ '#abcdef', 0xABAB, 0xCDCD, 0xEFEF ],
                  [ '#ABCDEF', 0xABAB, 0xCDCD, 0xEFEF ],

                  [ '#1234567' ],
                  [ '#12345678' ],

                  [ '#123456789', 0x1231, 0x4564, 0x7897 ],
                  [ '#abcbcdcde', 0xABCA, 0xBCDB, 0xCDEC ],

                  [ '#1234567890' ],
                  [ '#12345678901' ],

                  [ '#123456789ABC', 0x1234, 0x5678, 0x9ABC ],
                  [ '#abcdfedcdcba', 0xABCD, 0xFEDC, 0xDCBA ],

                  [ '#1234567890123' ],
                  [ '#12345678901234' ],
                  [ '#123456789012345' ],
                  [ '#1234567890123456' ],
                  [ '#12345678901234567' ],
                  [ '#123456789012345678' ],

                 ) {
  my ($hexstr, @want_rgb) = @$elem;
  my @got_rgb = App::MathImage::X11::Protocol::XSetRoot::_hexstr_to_rgb($hexstr);
  ok (scalar(@got_rgb), scalar(@want_rgb));
  ok ($got_rgb[0], $want_rgb[0]);
  ok ($got_rgb[1], $want_rgb[1]);
  ok ($got_rgb[2], $want_rgb[2]);
}


#------------------------------------------------------------------------------
# set_background()

{
  my $fields_before = join (',', sort keys %$X);
  my $grab = App::MathImage::X11::Protocol::XSetRoot->set_background
    (X => $X,
     pixel => $X->{'black_pixel'});
}


#------------------------------------------------------------------------------
$X->QueryPointer($X->{'root'});  # sync

exit 0;
