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

package App::MathImage::NumSeq::Sequence::DigitSumModulo;
use 5.004;
use strict;
use List::Util 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Base::Digits';

use vars '$VERSION';
$VERSION = 54;

use constant name => __('Digit Sum Modulo');
use constant description => __('Sum of the digits in the given radix, modulo that radix.  Eg. for binary this is the bitwise parity.');

# use constant oeis_anum => 'A001969'; # with even 1s
# df 'A026147'; # positions of 1s in evil
# cf A001285
# cf A053827 - base 6, full sum, not modulo
my @oeis = (undef,
            undef,
            'A010060', # 2 binary
            'A053838', # 3 ternary
            'A053839', # 4
            'A053840', # 5
            'A053841', # 6
            'A053842', # 7
            'A053843', # 8
            'A053844', # 9
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis[$radix];
}
# OeisCatalogue: A010060 radix=2
# OeisCatalogue: A053838 radix=3
# OeisCatalogue: A053839 radix=4
# OeisCatalogue: A053840 radix=5
# OeisCatalogue: A053841 radix=6
# OeisCatalogue: A053842 radix=7
# OeisCatalogue: A053843 radix=8
# OeisCatalogue: A053844 radix=9


# uncomment this to run the ### lines
#use Smart::Comments;

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}
sub ith {
  my ($self, $i) = @_;
  my $radix = $self->{'radix'};
  if ($radix == 2) {
    # bit count per example in perlfunc unpack()
    return ($i, unpack('%32b*', pack('I', $i)) & 1);
  } else {
    my $sum = 0;
    for (my $rem = $i; $rem; $rem = int($rem/$radix)) {
      $sum += ($rem % $radix);
    }
    return $sum % $radix;
  }
}
sub pred {
  my ($self, $n) = @_;
  return ($n >= 0 && $n < $self->{'radix'});
}
1;
__END__
