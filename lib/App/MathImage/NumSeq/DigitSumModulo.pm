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

package App::MathImage::NumSeq::DigitSumModulo;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 70;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');


# uncomment this to run the ### lines
#use Smart::Comments;


use Math::NumSeq::Base::Digits;
use constant parameter_info_array =>
  [ Math::NumSeq::Base::Digits->parameter_info_list,
    { name        => 'modulus',
      share_key   => 'modulus_0',
      type        => 'integer',
      display     => Math::NumSeq::__('Modulus'),
      default     => 0,
      minimum     => 0,
      width       => 3,
      description => Math::NumSeq::__('Modulus, or 0 to use the radix.'),
    }
  ];

use constant values_min => 0;
sub values_max {
  my ($self) = @_;
  if (my $modulus = $self->{'modulus'}) {
    return $modulus;
  }
  return $self->{'radix'} - 1;
}

use constant name => Math::NumSeq::__('Digit Sum Modulo');
use constant description => Math::NumSeq::__('Sum of the digits in the given radix, modulo that radix.  Eg. for binary this is the bitwise parity.');

# cf A001969  numbers with even 1s
#    A026147  numbers with ...
#    A001285  thue-morse
#
my @oeis = (undef,
            undef,

            'A010060', # 2 binary
            # OEIS-Catalogue: A010060 radix=2

            'A053838', # 3 ternary
            # OEIS-Catalogue: A053838 radix=3

            'A053839', # 4
            # OEIS-Catalogue: A053839 radix=4

            'A053840', # 5
            # OEIS-Catalogue: A053840 radix=5

            'A053841', # 6
            # OEIS-Catalogue: A053841 radix=6

            'A053842', # 7
            # OEIS-Catalogue: A053842 radix=7

            'A053843', # 8
            # OEIS-Catalogue: A053843 radix=8

            'A053844', # 9
            # OEIS-Catalogue: A053844 radix=9

            'A053837', # 10
            # OEIS-Catalogue: A053837 radix=10
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis[$radix];
}

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
  if (my $modulus = $self->{'modulus'}) {
    return $sum % $modulus;
  }
  return $sum % $radix;
}

sub pred {
  my ($self, $value) = @_;
  return ($value == int($value) && $value >= 0 && $value <= $self->values_max);
}

1;
__END__

=for stopwords Ryde Math-NumSeq

=head1 NAME

Math::NumSeq::DigitSumModulo -- digit sum taken modulo a given modulus

=head1 SYNOPSIS

 use Math::NumSeq::DigitSumModulo;
 my $seq = Math::NumSeq::DigitSumModulo->new (radix => 10,
                                              modulus => 9);
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The sum of digits in each i, taken modulo a given modulus.  For example at
i=123 with modulus 5 the value is 1+2+3=6, mod 5 = 1.

Modulus 0, which is the default, means modulo the radix.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for the behaviour common to all path classes.

=over 4

=item C<$seq = Math::NumSeq::DigitSumModulo-E<gt>new (radix =E<gt> $r, modulus =E<gt> $d)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the sum of the digits in C<$i> written in C<radix>, modulo the
C<modulus>.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> might occur as value in the sequence, which means
simply C<$value >= 0> and C<$value E<lt>= modulus>.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::DigitSum>,

=cut
