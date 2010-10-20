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
use Test::More tests => 152;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require POSIX;
POSIX::setlocale(POSIX::LC_ALL(), 'C'); # no message translations
require App::MathImage::Generator;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 27;
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
# App::MathImage::Values various classes

{
  my $gen = App::MathImage::Generator->new;
  foreach my $elem ([ 'All', 0,
                      [ 0, 1, 2, 3, 4, 5, 6, 7 ] ],
                    [ 'All', 17,
                      [ 17, 18, 19 ] ],

                    [ 'Odd', 1,
                      [ 1, 3, 5, 7, 9, 11, 13 ] ],
                    [ 'Odd', 6,
                      [ 7, 9, 11, 13 ] ],

                    [ 'Squares', 1,
                      [ 1, 4, 9, 16, 25 ] ],
                    [ 'Squares', 3,
                      [ 4, 9, 16, 25 ] ],

                    [ 'Cubes', 1,
                      [ 1, 8, 27, 64, 125 ] ],
                    [ 'Cubes', 3,
                      [ 8, 27, 64, 125 ] ],

                    [ 'Tetrahedral', 1,
                      [ 1, 4, 10, 20, 35, 56, 84, 120 ] ],

                    [ 'Triangular', 1,
                      [ 1, 3, 6, 10, 15, 21 ] ],
                    [ 'Triangular', 5,
                      [ 6, 10, 15, 21 ] ],

                    [ 'Pronic', 1,
                      [ 2, 6, 12, 20, 30, 42 ] ],
                    [ 'Pronic', 5,
                      [ 6, 12, 20, 30, 42 ] ],

                    [ 'Even', 0,
                      [ 0, 2, 4, 6, 8, 10, 12 ] ],
                    [ 'Even', 5,
                      [ 6, 8, 10, 12 ] ],

                    [ 'Fibonacci', 1,
                      [ 1, 1, 2, 3, 5, 8, 13, 21, 34, 55 ] ],

                    [ 'Perrin', 0,
                      [ 3, 0, 2, 3, 2, 5, 5, 7, 10, 12, 17 ] ],
                    [ 'Padovan', 0,
                      [ 1, 1, 1, 2, 2, 3, 4, 5, 7, 9, 12 ] ],

                    [ 'PellNumbers', 0,
                      [ 0, 1, 2, 5, 12, 29, 70, 169, 408, 985, 2378, 5741,
                        13860, 33461, 80782, 195025, 470832, 1136689,
                      ] ],
                    [ 'PellNumbers', 6,
                      [ 12, 29, 70, 169, 408, 985, 2378, 5741,
                        13860, 33461, 80782, 195025, 470832, 1136689,
                      ] ],

                    [ 'Primes', 1,
                      [ 2, 3, 5, 7, 11, 13, 17 ] ],
                    [ 'Primes', 10,
                      [ 11, 13, 17 ] ],

                    [ 'TwinPrimes', 0,
                      [ 3, 5, 7, 11, 13, 17, 19, 29, 31 ] ],
                    [ 'TwinPrimes', 10,
                      [ 11, 13, 17, 19, 29, 31 ] ],

                    [ 'TwinPrimes1', 0,
                      [ 3, 5, 11, 17, 29 ] ],
                    [ 'TwinPrimes1', 4,
                      [ 5, 11, 17, 29 ] ],

                    [ 'TwinPrimes2', 0,
                      [ 5, 7, 13, 19, 31 ] ],
                    [ 'TwinPrimes2', 6,
                      [ 7, 13, 19, 31 ] ],

                    # sloanes
                    # http://www.research.att.com/~njas/sequences/A001358
                    [ 'SemiPrimes', 0,
                      [ 4, 6, 9, 10, 14, 15, 21, 22, 25, 26, 33, 34, 35, 38,
                        39, 46, 49, 51, 55, 57, 58, 62, 65, 69, 74, 77, 82,
                        85, 86, 87, 91, 93, 94, 95, 106, 111, 115, 118, 119,
                        121, 122, 123, 129, 133, 134, 141, 142, 143, 145,
                        146, 155, 158, 159, 161, 166, 169, 177, 178, 183,
                        185, 187 ] ],

                    # [ 'SemiPrimesOdd', 0,
                    #   [ 9, 15, 21, 25, 33, 35,
                    #     39, 49, 51, 55, 57, 65, 69, 77,
                    #   ] ],

                    # http://www.research.att.com/~njas/sequences/A005384
                    [ 'SophieGermainPrimes', 0,
                      [ 2, 3, 5, 11, 23, 29, 41, 53, 83, 89, 113, 131, 173,
                        179, 191, 233, 239, 251, 281, 293, 359, 419, 431,
                        443, 491, 509, 593, 641, 653, 659, 683, 719, 743,
                        761, 809, 911, 953, 1013, 1019, 1031, 1049, 1103,
                        1223, 1229, 1289, 1409, 1439, 1451, 1481, 1499,
                        1511, 1559 ] ],

                    # http://www.research.att.com/~njas/sequences/A005385
                    [ 'SafePrimes', 0,
                      [ 5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263,
                        347, 359, 383, 467, 479, 503, 563, 587, 719, 839,
                        863, 887, 983, 1019, 1187, 1283, 1307, 1319, 1367,
                        1439, 1487, 1523, 1619, 1823, 1907, 2027, 2039,
                        2063, 2099, 2207, 2447, 2459, 2579, 2819, 2879, 2903,
                        ] ],

                    # sloanes
                    # http://www.research.att.com/~njas/sequences/A005224
                    [ 'Aronson', 0,
                      [ 1, 4, 11, 16, 24, 29, 33, 35, 39, 45, 47, 51, 56, 58,
                        62, 64, 69, 73, 78, 80, 84, 89, 94, 99, 104, 111,
                        116, 122, 126, 131, 136, 142, 147, 158, 164, 169,
                        174, 181, 183, 193, 199, 205, 208, 214, 220, 226,
                        231, 237, 243, 249, 254, 270, 288, 303, 307, 319,
                        323, 341 ],
                      { aronson_conjunctions => 0 },
                      'Math::Aronson',
                    ],

                    # sloanes
                    # http://www.research.att.com/%7Enjas/sequences/A079000
                    [ 'NumaronsonA', 0,
                      [ 1, 4, 6, 7, 8, 9, 11, 13, 15, 16, 17, 18, 19, 20,
                        21, 23, 25, 27, 29, 31, 33, 34, 35, 36, 37, 38, 39,
                        40, 41, 42, 43, 44, 45, 47, 49, 51, 53, 55, 57, 59,
                        61, 63, 65, 67, 69, 70, 71, 72, 73, 74, 75, 76, 77,
                        78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
                        91, 92, 93, 95, 97 ],
                    ],

                    [ 'ThueMorseEvil', 0,
                      [ 0, 3, 5, 6, 9, 10, 12, 15, 17, 18, 20, 23, 24, 27,
                        29, 30, 33, 34, 36, 39, 40, 43, 45, 46, 48, 51, 53,
                        54, 57, 58, 60, 63, 65, 66, 68, 71, 72, 75, 77, 78,
                        80, 83, 85, 86, 89, 90, 92, 95, 96, 99, 101, 102,
                        105, 106, 108, 111, 113, 114, 116, 119, 120, 123,
                        125, 126, 129 ] ],
                    [ 'ThueMorseEvil', 1, [ 3, 5, 6, 9 ] ],
                    [ 'ThueMorseEvil', 2, [ 3, 5, 6, 9 ] ],
                    [ 'ThueMorseEvil', 3, [ 3, 5, 6, 9 ] ],
                    [ 'ThueMorseEvil', 4, [ 5, 6, 9 ] ],
                    [ 'ThueMorseEvil', 5, [ 5, 6, 9 ] ],

                    [ 'ThueMorseOdious', 0,
                      [ 1, 2, 4, 7, 8, 11, 13, 14, 16, 19, 21, 22, 25, 26,
                        28, 31, 32, 35, 37, 38, 41, 42, 44, 47, 49, 50, 52,
                        55, 56, 59, 61, 62, 64, 67, 69, 70, 73, 74, 76, 79,
                        81, 82, 84, 87, 88, 91, 93, 94, 97, 98, 100, 103,
                        104, 107, 109, 110, 112, 115, 117, 118, 121, 122,
                        124, 127, 128 ] ],
                    [ 'ThueMorseOdious', 1, [ 1, 2, 4, 7, ] ],
                    [ 'ThueMorseOdious', 2, [ 2, 4, 7, ] ],
                    [ 'ThueMorseOdious', 3, [ 4, 7, ] ],
                    [ 'ThueMorseOdious', 4, [ 4, 7, ] ],
                    [ 'ThueMorseOdious', 5, [ 7, ] ],

                    # A030190 bits, A030303 positions of 1s
                    [ 'ChampernowneBinary', 0,
                      [ 1, 2, 4, 5, 6, 9, 11, 12, 13, 15, 16, 17, 18, 22,
                        25, 26, 28, 30, 32, 33, 34, 35, 38, 39, 41, 42, 43,
                        44, 46, 47, 48, 49, 50, 55, 59, 60, 63, 65, 68, 69,
                        70, 72, 75, 77, 79, 80, 82, 83, 85, 87, 88, 89, 90,
                        91, 95, 96, 99, 100, 101, 103, 105 ] ],

                    # A083652
                    [ 'BinaryLengths', 0,
                      [ 1, 2, 4, 6, 9, 12, 15, 18, 22, 26, 30, 34, 38, 42,
                        46, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100,
                        105, 110, 115, 120, 125, 130, 136, 142, 148, 154,
                        160, 166, 172, 178, 184, 190, 196, 202, 208, 214,
                        220, 226, 232, 238, 244, 250, 256, 262, 268, 274,
                        280, 286, 292 ] ],

                    [ 'Base4Without3', 0,
                      [ 0x00, 0x01, 0x02,    # 0,1,2
                        0x04, 0x05, 0x06,    # 10,11,12
                        0x08, 0x09, 0x0A,    # 20,21,22
                        0x10, 0x11, 0x12,    # 100,101,102
                        0x14, 0x15, 0x16,
                      ] ],

                    [ 'TernaryWithout2', 0,
                      [ 0, 1,    # 0,1
                        3, 4,    # 10, 11
                        # 6, 7,    # 20, 21
                        9, 10,   # 100, 101
                        12, 13,  # 110, 111
                        27, 28,  # 1000, 1001
                      ] ],

                    [ 'RepdigitBase10', 0,
                      [ 0,
                        1,2,3,4,5,6,7,8,9,
                        11,22,33,44,55,66,77,88,99,
                        111,222,333,444,555,666,777,888,999,
                      ] ],

                    [ 'Pentagonal', 0,
                      [ 0,1,5,12,22 ] ],
                    [ 'PentagonalSecond', 0,
                      [ 0,2,7,15,26 ] ],
                    [ 'PentagonalGeneralized', 0,
                      [ 0,0,1,2,5,7,12,15,22,26 ] ],

                    [ 'FractionBits', 0,
                      [ 1,2,3 ],
                      { fraction => '7' } ],
                    [ 'FractionBits', 0,
                      [ 1,3,5,7,9,11,13 ],
                      { fraction => '1/3' } ],

                    [ 'PrimeQuadraticEuler', 0,
                      [ 41, 43, 47, 53, 61, 71, 83, 97, 113, 131, 151 ] ],
                    [ 'PrimeQuadraticLegendre', 0,
                      [ 29, 31, 37, 47, 61, 79, 101, 127, 157, 191, 229 ] ],
                    [ 'PrimeQuadraticHonaker', 0,
                      [ 59, 67, 83, 107, 139, 179, 227, 283, 347, 419, 499 ] ],

                   ) {
    my ($values, $lo, $want, $options, $module) = @$elem;
    if ($options) {
      %$gen = (%$gen, %$options);
    }
    my $hi = $want->[-1];

  SKIP: {
      my $values_class = "App::MathImage::Values::$values";
      my $values_obj;
      require Module::Load;
      if (! eval { Module::Load::load ($values_class);
                   $values_obj = $values_class->new (lo => $lo,
                                                     hi => $hi,
                                                     %$options);
                   1; }) {
        my $err = $@;
        diag "values=$values caught error -- $err";
        if ($module && ! eval "require $module; 1") {
          skip "values=$values due to no module $module", 2;
        }
        die $err;
      }

      my $got = [ map {($values_obj->next)[0]} 0 .. $#$want ];
      diag "$values ".join(',',@$got);
      is_deeply ($got, $want, "$values lo=$lo hi=$hi");

    SKIP: {
        $values_obj->can('pred')
          or skip "no pred() for $values_obj", 1;

        if ($hi > 1000) {
          $hi = 1000;
          $want = [ grep {$_<=$hi} @$want ];
        }
        my @got_pred;
        foreach my $n ($lo .. $hi) {
          ### $n
          if ($values_obj->pred($n)) {
            push @got_pred, $n;
          }
        }
        ### @got_pred
        _delete_duplicates($want);
        ### $want
        is_deeply (\@got_pred, $want, "$values_obj pred() lo=$lo hi=$hi");
      }
    }
  }
}

sub _delete_duplicates {
  my ($arrayref) = @_;
  my %seen;
  @seen{@$arrayref} = ();
  @$arrayref = sort {$a<=>$b} keys %seen;
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
                                              values => 'All');
    my $image = Image::Base::Text->new
      (-width  => 10,
       -height => 10,
       -cindex => { 'black' => ' ',
                    'white' => '*'});
    $gen->draw_Image ($image);
    $gen->description; # exercise description string
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
    if ($values eq 'Expression' && ! eval { require Math::Symbolic }) {
      diag "skip $values due to no Math::Symbolic -- $@";
      next;
    }
    if ($values eq 'Aronson' && ! eval { require Math::Aronson }) {
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
    $gen->description; # exercise description string
  }
  ok ($good, "all values_choices exercised");
}

#------------------------------------------------------------------------------

diag "Math::Prime::XS version ", Math::Prime::XS->VERSION;

exit 0;
