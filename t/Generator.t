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
use Test::More tests => 36;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require POSIX;
POSIX::setlocale(POSIX::LC_ALL(), 'C'); # no message translations
require App::MathImage::Generator;

sub complement {
  my ($aref) = @_;
  my %aref;
  @aref{@$aref} = (); # hash slice
  return [ grep {! $aref{$_}} $aref->[0] .. $aref->[-1] ];
}

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 42;
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
