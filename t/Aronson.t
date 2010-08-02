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

use 5.004;
use strict;
use warnings;
use Test::More tests => 6;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require App::MathImage::Aronson;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 13;
  is ($App::MathImage::Aronson::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::Aronson->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::Aronson->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Aronson->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}

#------------------------------------------------------------------------------

foreach my $elem ([ { lang => 'en' },
                    [ 1, 4, 11, 16, 24, 29, 33, 35, 39, 45, 47, 51, 56, 58,
                      62, 64, 69, 73, 78, 80, 84, 89, 94, 99, 104, 111,
                      116, 122, 126, 131, 136, 142, 147, 158, 164, 169,
                      174, 181, 183, 193, 199, 205, 208, 214, 220, 226,
                      231, 237, 243, 249, 254, 270, 288, 303, 307, 319,
                      323, 341 ] ],

                  # per Sloane's A080520
                  [ { lang => 'fr',
                      conjunctions => 1 },
                    [ 1, 2, 9, 12, 14, 16, 20, 22, 24, 28, 30, 36, 38, 47,
                      49, 51, 55, 57, 64, 66, 73, 77, 79, 91, 93, 104, 106,
                      109, 113, 115, 118, 121, 126, 128, 131, 134, 140, 142,
                      150, 152, 156, 158, 166, 168, 172, 174, 183, 184, 189,
                      191, 200, 207, 209, 218, 220, 224, 226, 234, 241 ] ],
                 ) {
  my ($options, $want) = @$elem;
  my $aronson = App::MathImage::Aronson->new (%$options);
  my @got = map {$aronson->next} 1 .. @$want;
  is_deeply (\@got, $want);
}

exit 0;
