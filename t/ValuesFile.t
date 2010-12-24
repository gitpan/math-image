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
use Test::More tests => 11;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use App::MathImage::ValuesFile;
use App::MathImage::ValuesFileWriter;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 37;
  is ($App::MathImage::ValuesFile::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::ValuesFile->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::ValuesFile->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::ValuesFile->VERSION($check_version); 1 },
      "VERSION class check $check_version");


  is ($App::MathImage::ValuesFileWriter::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::ValuesFileWriter->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::ValuesFileWriter->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  ok (! eval { App::MathImage::ValuesFileWriter->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
{
  my @values = (1, 2, 5, 19, 1234, 9999);
  my $hi = 10000;
  {
    diag "ValuesFileWriter create";
    my $vfw = App::MathImage::ValuesFileWriter->new
      (hi => $hi,
       package => 'ValuesFile-test');
    foreach my $n (@values) {
      $vfw->write_n ($n);
    }
    $vfw->done;
  }

  {
    diag "ValuesFile past hi";
    my $vf = App::MathImage::ValuesFile->new
      (hi => $hi+1,
       package => 'ValuesFile-test');
    is ($vf, undef);
  }
  {
    diag "ValuesFile read";
    my $vf = App::MathImage::ValuesFile->new
      (hi => $hi,
       package => 'ValuesFile-test');
    is ($vf->{'hi'}, $hi);

    my $got_arrayref = [ map {$vf->next} 1..30 ];
    diag "got @$got_arrayref";
    is_deeply ($got_arrayref, \@values, 'ValuesFile next()');
  }
}

exit 0;


