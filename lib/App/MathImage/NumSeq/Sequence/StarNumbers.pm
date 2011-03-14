# Copyright 2010, 2011 Kevin Ryde

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

package App::MathImage::NumSeq::Sequence::StarNumbers;
use 5.004;
use strict;
use warnings;
use POSIX 'ceil';
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 48;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Star Numbers');
use constant description =>  __('The star numbers 1, 13, 37, 73, 121, etc, 6*n*(n-1)+1, also called the centred 12-gonals.');
use constant values_min => 1;

# A003154 - star numbers
# A006060 - which are also triangular numbers
#     A068774 - indices of the triangulars
#     A068775 - indices of the stars
# A006061 - which are also perfect squares
#     A054320 - indices of the squares
#     A068778 - indices of the stars
#
use constant oeis => 'A003154';
# OeisCatalogue: A003154

# entered polygonal numbers (k*n^2-k*n+2)/2, for k = 3 through 14 sides:
# A005448 , A001844 , A005891 , A003215 , A069099 , A016754 , A060544 ,
# A062786 , A069125 , A003154 , A069126 , A069127
#
# centered polygonal numbers (k*n^2-k*n+2)/2, for k = 15 through 20 sides:
# A069128 , A069129 , A069130 , A069131 , A069132 , A069133

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { i => ceil(_inverse(max(1,$lo))),
               }, $class;
}
sub next {
  my ($self) = @_;
  return $self->ith($self->{'i'}++);
}
sub pred {
  my ($class_or_self, $n) = @_;
  if ($n < 0) { return 0; }
  # FIXME: the _inverse() +3 etc might be lost to rounding for very big $n
  my $i = _inverse($n);
  return ($i == int($i));
}
sub ith {
  my ($class_or_self, $i) = @_;
  return 6*$i*($i-1)+1;
}

# i = 1/2 + sqrt(1/6 * $n + 1/12)
#   = (3 + sqrt(6 * $n + 3)) / 6

sub _inverse {
  my ($n) = @_;
  return (sqrt(6*$n + 3) + 3) / 6;
}

1;
__END__
