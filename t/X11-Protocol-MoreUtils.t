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

my $test_count = 9;
plan tests => $test_count;

my $have_x11_protocol = eval { require X11::Protocol; 1 };
if (! $have_x11_protocol) {
  MyTestHelpers::diag ('X11::Protocol not available -- ',$@);
  foreach (1 .. $test_count) {
    skip ('X11::Protocol not available', 1, 1);
  }
  exit 0;
}
MyTestHelpers::diag ("X11::Protocol version ", X11::Protocol->VERSION);

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

require App::MathImage::X11::Protocol::MoreUtils;

#------------------------------------------------------------------------------
# VERSION

my $want_version = 45;
ok ($App::MathImage::X11::Protocol::MoreUtils::VERSION,
    $want_version,
    'VERSION variable');
ok (App::MathImage::X11::Protocol::MoreUtils->VERSION,
    $want_version,
    'VERSION class method');

ok (eval { App::MathImage::X11::Protocol::MoreUtils->VERSION($want_version); 1 },
    1,
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::X11::Protocol::MoreUtils->VERSION($check_version); 1 },
    1,
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# visual_class_is_dynamic()

{
  my $visual_class = 'PseudoColor';
  ok (App::MathImage::X11::Protocol::MoreUtils::visual_class_is_dynamic($X,$visual_class),
      1,
      "visual_class_is_dynamic() $visual_class");
}
{
  my $visual_class = 3;
  ok (App::MathImage::X11::Protocol::MoreUtils::visual_class_is_dynamic($X,$visual_class),
      1,
      "visual_class_is_dynamic() $visual_class");
}
{
  my $visual_class = 'TrueColor';
  ok (App::MathImage::X11::Protocol::MoreUtils::visual_class_is_dynamic($X,$visual_class),
      0,
      "visual_class_is_dynamic() $visual_class");
}
{
  my $visual_class = 4;
  ok (App::MathImage::X11::Protocol::MoreUtils::visual_class_is_dynamic($X,$visual_class),
      0,
      "visual_class_is_dynamic() $visual_class");
}

#------------------------------------------------------------------------------
# visual_is_dynamic()

{
  my $good = 1;
  foreach (keys %{$X->{'visuals'}}) {
    my $visual_id = $_;
    my $visual_class = $X->{'visuals'}->{$visual_id}->{'class'};
    my $got = App::MathImage::X11::Protocol::MoreUtils::visual_is_dynamic($X,$visual_id);
    my $want = App::MathImage::X11::Protocol::MoreUtils::visual_class_is_dynamic($X,$visual_class);
    if ($got != $want) {
      MyTestHelpers::diag ("wrong: visual_id $visual_id visual_class $visual_class got $got want $want");
      $good = 0;
    }
  }
  ok ($good, 1,
     'visual_is_dynamic() ');
}

#------------------------------------------------------------------------------
$X->QueryPointer($X->{'root'});  # sync

exit 0;
