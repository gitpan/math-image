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

package App::MathImage::NumSeq::Sequence::Tetrahedral;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sparse';

use vars '$VERSION';
$VERSION = 50;

use constant name => __('Tetrahedral');
use constant description => __('The tetrahedral numbers 1, 4, 10, 20, 35, 56, 84, 120, etc, k*(k+1)*(k+2)/6.');
use constant oeis => 'A000292'; # tetrahedrals

sub rewind {
  my ($self) = @_;

  # ENHANCE-ME: cbrt() inverse to set i from requested $lo
  my $i = 0;
  while ($self->ith($i) < $self->{'lo'}) {
    $i++;
  }
  $self->{'i'} = $i;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}
sub ith {
  my ($class_or_self, $i) = @_;
  return $i*($i+1)*($i+2)/6;
}

1;
__END__
