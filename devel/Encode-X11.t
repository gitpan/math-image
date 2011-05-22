#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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

use 5.004;
use strict;
use warnings;
use Test::More tests => 5;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

eval { require Encode }
  or plan skip_all => "due to no Encode module -- $@";

require App::MathImage::Encode::X11;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 58;
  is ($App::MathImage::Encode::X11::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::Encode::X11->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::Encode::X11->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Encode::X11->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}

#------------------------------------------------------------------------------
# round trip

my @ords = grep { ! (($_ >= 0x80 && $_ <= 0x9F)
                     || ($_ >= 0xD800 && $_ <= 0xDFFF)
                     || ($_ >= 0xFDD0 && $_ <= 0xFDEF)
                     || ($_ >= 0xFFFE && $_ <= 0xFFFF)
                     || ($_ >= 0x1FFFE && $_ <= 0x1FFFF)) }
  32 .. 0x2FA1D;

{
  my $good = 1;
  foreach my $i (@ords) {
    my $chr = chr($i);
    my $input_chr = $chr;
    my $bytes = Encode::encode('x11-compound-text', $input_chr,
                               Encode::FB_QUIET());
    next if length $chr;
    my $input_bytes = $bytes;
    my $decode = Encode::decode('x11-compound-text', $input_bytes,
                                Encode::FB_QUIET());
    if ($input_bytes) {
      diag sprintf "U+%04X remaining bytes: %s\n", $i, bytestr($input_bytes);
      $good = 0;
    }
    if ($decode ne $chr) {
      diag sprintf "U+%04X got %s want %s\n", $i, bytestr($decode), bytestr($chr);
      $good = 0;
    }
  }
  ok ($good);
}

exit 0;
