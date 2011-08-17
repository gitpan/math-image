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


# separate modulus parameter ...


package App::MathImage::NumSeq::DigitSumModulo;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 67;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
use Math::NumSeq::Base::Digits;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq::Base::Digits');

use constant name => Math::NumSeq::__('Digit Sum Modulo');
use constant description => Math::NumSeq::__('Sum of the digits in the given radix, modulo that radix.  Eg. for binary this is the bitwise parity.');

# use constant oeis_anum => 'A001969'; # with even 1s
# cf 'A026147'; # positions of 1s in evil
# cf A001285
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
            'A053837', # 10
           );
# OEIS-Catalogue: A010060 radix=2
# OEIS-Catalogue: A053838 radix=3
# OEIS-Catalogue: A053839 radix=4
# OEIS-Catalogue: A053840 radix=5
# OEIS-Catalogue: A053841 radix=6
# OEIS-Catalogue: A053842 radix=7
# OEIS-Catalogue: A053843 radix=8
# OEIS-Catalogue: A053844 radix=9
# OEIS-Catalogue: A053837 radix=10
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis[$radix];
}


# uncomment this to run the ### lines
#use Smart::Comments;

# ENHANCE-ME:
# next() is +1 mod m, except when xx09 wraps to xx10 which is +2,
# or when x099 to x100 then +3, etc extra is how many low 9s
#
# sub next {
#   my ($self) = @_;
#   my $radix = $self->{'radix'};
#   my $sum = $self->{'sum'} + 1;
#   if (++$self->{'digits'}->[0] >= $radix) {
#     $self->{'digits'}->[0] = 0;
#     my $i = 1;
#     for (;;) {
#       $sum++;
#       if (++$self->{'digits'}->[$i] < $radix) {
#         last;
#       }
#     }
#   }
#   return ($self->{'i'}++, ($self->{'sum'} = ($sum % $radix)));
# }
  
sub ith {
  my ($self, $i) = @_;
  my $radix = $self->{'radix'};
  # if ($radix == 2) {
  #   # bit count per example in perlfunc unpack()
  #   return ($i, unpack('%32b*',pack('I',$i)) & 1);
  # } else {
  # }

  my $sum = 0;
  for (my $rem = $i; $rem; $rem = int($rem/$radix)) {
    $sum += ($rem % $radix);
  }
  return $sum % $radix;
}

1;
__END__
