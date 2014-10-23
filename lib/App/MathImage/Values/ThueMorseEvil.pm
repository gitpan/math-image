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

package App::MathImage::Values::ThueMorseEvil;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 27;


# FIXME: parameter for odd/even instead of sep series?
# ENHANCE-ME: maybe a radix parameter, modulo sum of digits

# http://www.research.att.com/~njas/sequences/A026147
# bit count per example in perlfunc unpack()

use constant name => __('Thue-Morse Evil Numbers');
use constant description => __('The Thue-Morse "evil" numbers, meaning numbers with an even number of 1s in their binary form (the opposite of the "odious"s).');

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  $lo = max ($lo, 0); # no negatives

  # i initially the first $i < $lo satisfying pred(), but no further back
  # than -1
  my $i = $lo-1;
  while ($i >= 0 && ! $class->pred($i)) {
    $i--;
  }
  return bless { i => $i,
               }, $class;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'};
  if (! ($i & 3)) {
    ### 0b...00 next same parity 0b...11 which is +3
    return ($self->{'i'} += 3);
  }
  if (($i & 3) == 1) {
    ### 0b...01 next same parity 0b...10 which is +1
    return ($self->{'i'} += 1);
  }
  if (($i & 6) == 2) {
    ### 0b...01. next same parity 0b...10. which is +2
    return ($self->{'i'} += 2);
  }
  # search
  until ($self->pred(++$i)) { }
  return (($self->{'i'} = $i),
          1);
}

sub pred {
  my ($self, $n) = @_;
  return ! (1 & unpack('%32b*', pack('I', $n)));
}
1;
__END__
