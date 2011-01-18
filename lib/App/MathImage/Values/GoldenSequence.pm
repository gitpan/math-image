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

package App::MathImage::Values::GoldenSequence;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use POSIX 'ceil';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 42;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Golden Sequence');
# use constant description => __('');
use constant oeis => 'A000201'; #  1,3,4,6,8,9,11,12
# A003849  0,1,1,0,1,0,1
# OEIS: A000201

use constant PHI => (1 + sqrt(5)) / 2;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  $lo = max (1, $lo);

  return bless { i => ceil ($lo / PHI),
               }, $class;
}
sub next {
  my ($self) = @_;
  ### i: $self->{'i'}
  ### i*PHI: $self->{'i'}*PHI
  return int ($self->{'i'}++ * PHI);
}

sub pred {
  my ($self, $n) = @_;
  if ($n <= 0) { return 0; }
  return (int (ceil($n/PHI) * PHI) == $n);
}

1;
__END__

