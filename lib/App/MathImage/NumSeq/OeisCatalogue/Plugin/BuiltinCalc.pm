# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::NumSeq::OeisCatalogue::Plugin::BuiltinCalc;
use 5.004;
use strict;
use List::Util 'min', 'max'; # FIXME: 5.6 only, maybe

use vars '@ISA';
use App::MathImage::NumSeq::OeisCatalogue::Base;
@ISA = ('App::MathImage::NumSeq::OeisCatalogue::Base');

use vars '$VERSION';
$VERSION = 47;

# uncomment this to run the ### lines
#use Smart::Comments;

sub _make_frac {
  my ($num) = @_;
  return { num => $num,
             class => 'App::MathImage::NumSeq::Sequence::Digits::Fraction',
             parameters_hashref => { fraction => '1/'.($num-21004) } };
}

use constant num_first => 21016;
use constant num_last  => 22003;

sub num_after {
  my ($class, $num) = @_;
  if ($num < num_last()) {
    return max ($num+1, num_first());
  }
  return undef;
}
sub num_before {
  my ($class, $num) = @_;
  if ($num > num_first()) {
    return min ($num-1, num_last());
  }
  return undef;
}

sub num_to_info {
  my ($class, $num) = @_;
  ### Catalogue-BuiltinCalc num_to_info(): @_

  # App::MathImage::NumSeq::Sequence::Digits::Fraction
  # fraction=1/k radix=10 for k=11 to 999 is anum=21004+k,
  # being A021015 through A022003, though 1/11 is also A010680 and prefer
  # that one (in BuiltinTable)

  if ($num >= num_first() && $num <= num_last()) {
    return _make_frac($num);
  }
  return undef;
}

my @info_array;
sub info_arrayref {
  my ($class) = @_;

  if (! @info_array) {
    @info_array = map {_make_frac($_)} num_first() .. num_last();
  }
  return \@info_array;
}

1;
__END__

