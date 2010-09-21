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
use Test::More tests => 66;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require POSIX;
POSIX::setlocale(POSIX::LC_ALL(), 'C'); # no message translations
require App::MathImage::Generator;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 21;
  is ($App::MathImage::Generator::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::Generator->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::Generator->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Generator->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}

#------------------------------------------------------------------------------
# line_clipper()

foreach my $elem ([ [ 0,0, 0,0, 1,1 ],
                    [ 0,0, 0,0 ] ],
                  [ [ -5,0, 5,0, 10,10],
                    [ 0,0, 5,0 ] ],
                  [ [ -5,0, 15,0, 10,10],
                    [ 0,0, 9,0 ] ],

                  [ [ 0,-5, 0,5, 10,10],
                    [ 0,0, 0,5 ] ],
                  [ [ 0,-5, 0,15, 10,10],
                    [ 0,0, 0,9 ] ],

                  [ [ -5,0, -4,0, 10,10],
                    [  ] ],
                  [ [ 0,-5, 0,-4, 10,10],
                    [  ] ],
                  [ [ 15,0, 14,0, 10,10],
                    [  ] ],
                  [ [ 0,15, 0,14, 10,10],
                    [  ] ],

                  [ [ -5,5, 5,-5, 10,10],
                    [ 0,0, 0,0 ] ],
                  [ [ -5,1, 5,-6, 10,10],
                    [ ] ],

                  [ [ 2,-1, -1,2, 10,10],
                    [ 1,0, 0,1] ],
                  [ [ 7,10, 10,7, 10,10],
                    [ 8,9, 9,8] ],
                  [ [ 7,-1, 10,2, 10,10],
                    [ 8,0, 9,1] ],
                  [ [ -1,7, 2,10, 10,10],
                    [ 0,8, 1,9] ],


                 ) {
  my ($args, $want_array) = @$elem;
  my ($x1,$y1, $x2,$y2, $width,$height) = @$args;
  {
    my $got_array = [ App::MathImage::Generator::line_clipper ($x1,$y1, $x2,$y2, $width,$height) ];
    my $want = join(',',@$want_array);
    my $got = join(',',@$got_array);
    is ($got, $want, "line_clipper() ".join(',',@$args));
  }

  ($x1,$y1, $x2,$y2) = ($x2,$y2, $x1,$y1);
  if (my ($want_x1,$want_y1, $want_x2,$want_y2) = @$want_array) {
    @$want_array = ($want_x2,$want_y2, $want_x1,$want_y1);
  }
  {
    my $got_array = [ App::MathImage::Generator::line_clipper ($x1,$y1, $x2,$y2, $width,$height) ];
    my $want = join(',',@$want_array);
    my $got = join(',',@$got_array);
    is ($got, $want, "line_clipper() ".join(',',@$args));
  }
}

#------------------------------------------------------------------------------
# values_make funcs

{
  my %values_choices;
  foreach my $values (App::MathImage::Generator->values_choices) {
    $values_choices{$values} = 1;
  }

  my $gen = App::MathImage::Generator->new;
  foreach my $elem ([ 'values_make_all', 0,
                      [ 0, 1, 2, 3, 4, 5, 6, 7 ] ],
                    [ 'values_make_all', 17,
                      [ 17, 18, 19 ] ],

                    [ 'values_make_odd', 1,
                      [ 1, 3, 5, 7, 9, 11, 13 ] ],
                    [ 'values_make_odd', 6,
                      [ 7, 9, 11, 13 ] ],

                    [ 'values_make_squares', 1,
                      [ 1, 4, 9, 16, 25 ] ],
                    [ 'values_make_squares', 3,
                      [ 4, 9, 16, 25 ] ],

                    [ 'values_make_cubes', 1,
                      [ 1, 8, 27, 64, 125 ] ],
                    [ 'values_make_cubes', 3,
                      [ 8, 27, 64, 125 ] ],

                    [ 'values_make_tetrahedral', 1,
                      [ 1, 4, 10, 20, 35, 56, 84, 120 ] ],

                    [ 'values_make_triangular', 1,
                      [ 1, 3, 6, 10, 15, 21 ] ],
                    [ 'values_make_triangular', 5,
                      [ 6, 10, 15, 21 ] ],

                    [ 'values_make_pronic', 1,
                      [ 2, 6, 12, 20, 30, 42 ] ],
                    [ 'values_make_pronic', 5,
                      [ 6, 12, 20, 30, 42 ] ],

                    [ 'values_make_even', 0,
                      [ 0, 2, 4, 6, 8, 10, 12 ] ],
                    [ 'values_make_even', 5,
                      [ 6, 8, 10, 12 ] ],

                    [ 'values_make_fibonacci', 1,
                      [ 1, 1, 2, 3, 5, 8, 13, 21, 34, 55 ] ],

                    [ 'values_make_perrin', 0,
                      [ 3, 0, 2, 3, 2, 5, 5, 7, 10, 12, 17 ] ],
                    [ 'values_make_padovan', 0,
                      [ 1, 1, 1, 2, 2, 3, 4, 5, 7, 9, 12 ] ],


                    [ 'values_make_primes', 1,
                      [ 2, 3, 5, 7, 11, 13, 17 ] ],
                    [ 'values_make_primes', 10,
                      [ 11, 13, 17 ] ],

                    [ 'values_make_twin_primes', 0,
                      [ 3, 5, 7, 11, 13, 17, 19, 29, 31 ] ],
                    [ 'values_make_twin_primes', 10,
                      [ 11, 13, 17, 19, 29, 31 ] ],

                    [ 'values_make_twin_primes_1', 0,
                      [ 3, 5, 11, 17, 29 ] ],
                    [ 'values_make_twin_primes_1', 4,
                      [ 5, 11, 17, 29 ] ],

                    [ 'values_make_twin_primes_2', 0,
                      [ 5, 7, 13, 19, 31 ] ],
                    [ 'values_make_twin_primes_2', 6,
                      [ 7, 13, 19, 31 ] ],

                    # sloanes
                    # http://www.research.att.com/~njas/sequences/A001358
                    [ 'values_make_semi_primes', 0,
                      [ 4, 6, 9, 10, 14, 15, 21, 22, 25, 26, 33, 34, 35, 38,
                        39, 46, 49, 51, 55, 57, 58, 62, 65, 69, 74, 77, 82,
                        85, 86, 87, 91, 93, 94, 95, 106, 111, 115, 118, 119,
                        121, 122, 123, 129, 133, 134, 141, 142, 143, 145,
                        146, 155, 158, 159, 161, 166, 169, 177, 178, 183,
                        185, 187 ] ],

                    # sloanes
                    # http://www.research.att.com/~njas/sequences/A005224
                    [ 'values_make_aronson', 0,
                      [ 1, 4, 11, 16, 24, 29, 33, 35, 39, 45, 47, 51, 56, 58,
                        62, 64, 69, 73, 78, 80, 84, 89, 94, 99, 104, 111,
                        116, 122, 126, 131, 136, 142, 147, 158, 164, 169,
                        174, 181, 183, 193, 199, 205, 208, 214, 220, 226,
                        231, 237, 243, 249, 254, 270, 288, 303, 307, 319,
                        323, 341 ],
                      { aronson_conjunctions => 0 },
                      'Math::Aronson',
                    ],

                    [ 'values_make_thue_morse_evil', 0,
                      [ 0, 3, 5, 6, 9, 10, 12, 15, 17, 18, 20, 23, 24, 27,
                        29, 30, 33, 34, 36, 39, 40, 43, 45, 46, 48, 51, 53,
                        54, 57, 58, 60, 63, 65, 66, 68, 71, 72, 75, 77, 78,
                        80, 83, 85, 86, 89, 90, 92, 95, 96, 99, 101, 102,
                        105, 106, 108, 111, 113, 114, 116, 119, 120, 123,
                        125, 126, 129 ] ],
                    [ 'values_make_thue_morse_odious', 0,
                      [ 1, 2, 4, 7, 8, 11, 13, 14, 16, 19, 21, 22, 25, 26,
                        28, 31, 32, 35, 37, 38, 41, 42, 44, 47, 49, 50, 52,
                        55, 56, 59, 61, 62, 64, 67, 69, 70, 73, 74, 76, 79,
                        81, 82, 84, 87, 88, 91, 93, 94, 97, 98, 100, 103,
                        104, 107, 109, 110, 112, 115, 117, 118, 121, 122,
                        124, 127, 128 ] ],
                   ) {
    my ($method, $lo, $want, $options, $module) = @$elem;
    if ($options) {
      %$gen = (%$gen, %$options);
    }
  SKIP: {
      my $iter;
      if (! eval {
        $iter = $gen->$method ($lo, 1000);
        1;
      }) {
        my $err = $@;
        diag "method=$method caught error -- $err";
        if ($module && ! eval "require $module; 1") {
          skip "method=$method due to no module $module", 1
        }
        die $err;
      }

      my $got = [ map {$iter->()} 0 .. $#$want ];
      is_deeply ($got, $want, "$method lo=$lo");
    }
  }
}

#------------------------------------------------------------------------------
# path_choices

{
  my $good = 1;
  require Image::Base::Text;
  foreach my $path (App::MathImage::Generator->path_choices) {
    diag "exercise path $path";
    my $gen = App::MathImage::Generator->new (width  => 10,
                                              height => 10,
                                              scale  => 1,
                                              path   => $path,
                                              values => 'all');
    my $image = Image::Base::Text->new
      (-width  => 10,
       -height => 10,
       -cindex => { 'black' => ' ',
                    'white' => '*'});
    $gen->draw_Image ($image);
  }
  ok ($good, "all path_choices exercised");
}

#------------------------------------------------------------------------------
# values_choices

{
  require Image::Base::Text;
  my $good = 1;
  foreach my $values (App::MathImage::Generator->values_choices) {
    diag "exercise values $values";
    if ($values eq 'expression' && ! eval { require Math::Symbolic }) {
      diag "skip $values due to no Math::Symbolic -- $@";
      next;
    }
    if ($values eq 'aronson' && ! eval { require Math::Aronson }) {
      diag "skip $values due to no Math::Aronson -- $@";
      next;
    }

    my $gen = App::MathImage::Generator->new (width  => 10,
                                              height => 10,
                                              scale  => 1,
                                              path   => 'Rows',
                                              values => $values);
    my $image = Image::Base::Text->new
      (-width  => 10,
       -height => 10,
       -cindex => { 'black' => ' ',
                    'white' => '*'});
    $gen->draw_Image ($image);
  }
  ok ($good, "all values_choices exercised");
}

#------------------------------------------------------------------------------

diag "Math::Prime::XS version ", Math::Prime::XS->VERSION;

exit 0;
