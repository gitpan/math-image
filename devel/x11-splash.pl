#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


use 5.008;
use strict;
use warnings;

use X11::Protocol;
use App::MathImage::X11::Protocol::Splash;


# uncomment this to run the ### lines
use Smart::Comments;

{
  require FindBin;
  my $program = File::Spec->catfile ($FindBin::Bin, $FindBin::Script);
  ### $0
  ### $program
  ### @ARGV

  my $X = X11::Protocol->new;
  my $root = $X->{'root'};

  ### maximum_request_length: $X->{'maximum_request_length'}
  my $str = 'A' x (16384*1000);
  App::MathImage::X11::Protocol::Splash::_set_text_property
      ($X, $root, $X->atom('MY_FOO'), $str);

  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty ($root,
                       $X->atom('MY_FOO'),
                       'AnyPropertyType',
                       0,  # offset
                       length($str),  # length
                       0); # delete;
  ### value length: length($value)
  ### $type
  ### $format
  ### $bytes_after
  exit 0;
}

