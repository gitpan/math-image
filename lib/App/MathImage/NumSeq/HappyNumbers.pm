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

package App::MathImage::NumSeq::HappyNumbers;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 73;

use Math::NumSeq;
use Math::NumSeq::Base::IteratePred;
@ISA = ('Math::NumSeq::Base::IteratePred',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => Math::NumSeq::__('Happy Numbers');
use constant description => Math::NumSeq::__('Happy numbers, reaching 1 under iterating sum of squares of digits.');
use constant values_min => 1;
use constant characteristic_monotonic => 1;
use constant i_start => 1;

use Math::NumSeq::Base::Digits;
use constant parameter_info_array =>
  [ Math::NumSeq::Base::Digits::parameter_common_radix() ];

# cf A035497 happy primes
#
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return ($radix == 10
          ? 'A007770'
          : undef);
}
# OEIS-Catalogue: A007770 radix=10

# sub ith {
#   my ($self, $i) = @_;
#   return ...
# }

sub pred {
  my ($self, $value) = @_;
  ### HappyNumbers pred(): $value
  if ($value <= 0) {
    return 0;
  }
  my $radix = $self->{'radix'};
  my %seen;
  for (;;) {
    ### $value
    my $sum = 0;
    if ($value == 1) {
      return 1;
    }
    if ($seen{$value}) {
      return 0;  # inf loop
    }
    $seen{$value} = 1;
    while ($value) {
      my $digit = ($value % $radix);
      $sum += $digit * $digit;
      $value = int($value/$radix);
    }
    # if ($value == $sum) {
    #   return 0;
    # }
    $value = $sum;
  }
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::HappyNumbers -- happy numbers

=head1 SYNOPSIS

 use App::MathImage::NumSeq::HappyNumbers;
 my $seq = App::MathImage::NumSeq::HappyNumbers->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This sequence is the happy numbers, those where repeatedly taking the sum of
the squares of the digits eventually gives 1.

For example 23 is a happy number because 2*2+3*3=13, then 1*1+3*3=10, then
1*1+0*0=1.

In decimal it can be shown that this procedure always reaches one of the ten
values 0, 1, 4, 16, 20, 37, 42, 58, 89, 145.  Values which reach 1 are
called happy numbers.

An optional C<radix> parameter can select a base other than decimal.  Base 2
(binary) and base 4 are not very interesting since for them every number is
happy (except 0).

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::HappyNumbers-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is a happy number, meaning repeated sum of squares
of its digits reaches 1.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
