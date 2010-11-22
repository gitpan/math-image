# Copyright 2010 Kevin Ryde

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

package App::MathImage::Values::GolayRudinShapiro;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 31;

# uncomment this to run the ### lines
#use Smart::Comments;

# http://www.research.att.com/~njas/sequences/A020985
#     1 and -1
# http://www.research.att.com/~njas/sequences/A022155
#     Positions where negative.
#
# http://www.research.att.com/~njas/sequences/A020986
#     Nth partial sums of 1 and -1, variously up and down
# http://www.research.att.com/~njas/sequences/A020991
#     Highest occurrance of N in the partial sums.
#
# 
#
use constant name => __('Golay Rudin Shapiro');
use constant description => __('Numbers which have an odd number of "11" bit pairs in binary.');

use constant PHI => (1 + sqrt(5)) / 2;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  $lo = max (0, $lo);
  
  return bless { i => $lo,
               }, $class;
}
sub next {
  my ($self) = @_;
  for (;;) {
    if ($self->pred (my $i = $self->{'i'}++)) {
      return $i;
    }
  }
}

sub pred {
  my ($self, $n) = @_;
  if ($n < 0) { return 0; }
  $n &= ($n >> 1);
  return (1 & unpack('%32b*', pack('I', $n)));
}

1;
__END__

