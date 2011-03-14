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
use Test::More tests => 11;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use App::MathImage::NumSeq::File;
use App::MathImage::NumSeq::FileWriter;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 48;
  is ($App::MathImage::NumSeq::File::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::NumSeq::File->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::NumSeq::File->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::NumSeq::File->VERSION($check_version); 1 },
      "VERSION class check $check_version");


  is ($App::MathImage::NumSeq::FileWriter::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::NumSeq::FileWriter->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::NumSeq::FileWriter->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  ok (! eval { App::MathImage::NumSeq::FileWriter->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
{
  my @values = (1, 2, 5, 19, 1234, 9999);
  my $hi = 10000;
  {
    diag "NumSeq FileWriter create";
    my $vfw = App::MathImage::NumSeq::FileWriter->new
      (hi => $hi,
       package => 'NumSeq File-test');
    foreach my $n (@values) {
      $vfw->write_n ($n);
    }
    $vfw->done;
  }

  {
    diag "NumSeq File past hi";
    my $vf = App::MathImage::NumSeq::File->new
      (hi => $hi+1,
       package => 'NumSeq File-test');
    is ($vf, undef);
  }
  {
    diag "NumSeq File read";
    my $vf = App::MathImage::NumSeq::File->new
      (hi => $hi,
       package => 'NumSeq File-test');
    is ($vf->{'hi'}, $hi);

    my $got_arrayref = [ map {$vf->next} 1..30 ];
    diag "got @$got_arrayref";
    is_deeply ($got_arrayref, \@values, 'NumSeq File next()');
  }
}

exit 0;


