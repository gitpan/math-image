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

my $test_count = 26;
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

require App::MathImage::X11::Protocol::Splash;

#------------------------------------------------------------------------------
# VERSION

my $want_version = 47;
ok ($App::MathImage::X11::Protocol::Splash::VERSION,
    $want_version,
    'VERSION variable');
ok (App::MathImage::X11::Protocol::Splash->VERSION,
    $want_version,
    'VERSION class method');

ok (eval { App::MathImage::X11::Protocol::Splash->VERSION($want_version); 1 },
    1,
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::X11::Protocol::Splash->VERSION($check_version); 1 },
    1,
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# _wm_unpack_hints()

{
  my $format = 'LLLLLllLL';

  foreach my $elem ([ pack($format,0,(0)x8) ],
                    [ pack($format,0,(0)x7) ],  # short from X11R2 ?

                    [ pack($format,1,0,(0)x7), input => 0 ],
                    [ pack($format,1,1,(0)x7), input => 1 ],

                    [ pack($format,2,0,1,(0)x6), initial_state => 'NormalState' ],
                    [ pack($format,2,0,3,(0)x6), initial_state => 'IconicState' ],

                    [ pack($format, 16, 0,0,0,0, 123,456, 0,0),
                      icon_x => 123, icon_y => 456 ],
                    [ pack($format, 16, 0,0,0,0, -123,-456, 0,0),
                      icon_x => -123, icon_y => -456 ],

                    [ pack($format, 64, 0,0,0,0, 0,0, 0,0), window_group => 0 ],
                    [ pack($format, 64, 0,0,0,0, 0,0, 0,123), window_group => 123 ],
                    [ pack($format, 256, (0)x8), urgency => 1 ],
                   ) {
    my ($bytes, @want) = @$elem;
    my @got = App::MathImage::X11::Protocol::Splash::_wm_unpack_hints($bytes);
    my $good = 1;
    ok (scalar(@got), scalar(@want));
    for (my $i = 0; $i < @got && $i < @want; $i++) {
      unless ((! defined $got[$i] && ! defined $want[$i])
              || (defined $got[$i] && defined $want[$i]
                  && $got[$i] eq $want[$i])) {
        $good = 0;
        MyTestHelpers::diag ("Got ",$got[$i]," want ",$want[$i]);
      }
    }
    ok ($good, 1);
  }
}


#------------------------------------------------------------------------------
$X->QueryPointer($X->{'root'});  # sync

exit 0;
