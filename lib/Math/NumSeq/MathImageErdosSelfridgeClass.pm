# Copyright 2012 Kevin Ryde

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

package Math::NumSeq::MathImageErdosSelfridgeClass;
use 5.004;
use strict;
use Math::Factor::XS 0.39 'prime_factors'; # version 0.39 for prime_factors()
use Math::NumSeq::Primes;

use vars '$VERSION', '@ISA';
$VERSION = 96;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('Erdos-Selfridge class of a prime.');
use constant default_i_start => 1;
use constant characteristic_integer => 1;
use constant characteristic_increasing => 0;
use constant characteristic_non_decreasing => 0;
use constant characteristic_smaller => 1;
use constant values_min => 0;

use constant parameter_info_array =>
  [
   { name    => 'p_or_m',
     display => Math::NumSeq::__('+/-'),
     type    => 'enum',
     default => '+',
     choices => ['+','-'],
     description => Math::NumSeq::__('...'),
   },
  ];

# use constant oeis_anum => '';

sub ith {
  my ($self, $i) = @_;

  Math::NumSeq::Primes->pred($i)
      or return 0;

  my $offset = ($self->{'p_or_m'} eq '+' ? 1 : -1);
  my $ret = 0;
  my @this = ($i);
  while (@this) {
    $ret++;
    my %next;
    foreach my $prime (@this) {
      @next{prime_factors($prime + $offset)} = ();  # hash slice, for uniq
    }
    delete @next{2,3}; # hash slice, not 2 or 3
    @this = keys %next;
  }
  return $ret;
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0
          && $value == int($value));
}

1;
__END__

=for stopwords Ryde Math-NumSeq ie

=head1 NAME

Math::NumSeq::ErdosSelfridgeClass -- classification of primes

=head1 SYNOPSIS

 use Math::NumSeq::ErdosSelfridgeClass;
 my $seq = Math::NumSeq::ErdosSelfridgeClass->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

A classification of primes by Erdos and Selfridge, or 0 if composite.

    0,1,1,0,1,0,1,0,0,0,1,0,2,0,0,0,1,0,2,0,0,0,1,0,0,0,0,0,2,...

A prime p is classified according to the prime factors of p+1.  If the
maximum class among those factors is c then p has class one above that,
ie. c+1.

Primes 2 and 3 are reckoned as class 1, as are any primes where p+1 has
factors 2 and 3 only, p=2^x+3^y-1.  For example i=11 has 11+1=12=2*2*3 so
it's class 1.

The classification essentially asks how many iterations of factorizing p+1
it takes to get to down to factors 2 and 3 only.  For example i=617 has
617+1=2*3*103, then 103+1=104=2*13, then 13+1=2*7.  7 is a class 1, so 13 is
a class 2, 103 is class 3, and finally 617 is class 4.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::ErdosSelfridgeClass-E<gt>new ()>

Create and return a new sequence object.

=item C<$bool = $seq-E<gt>ith($value)>

Return the class number of C<$value>, or 0 if C<$value> is not a prime.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs as a classification in the sequence, which
means any integer C<$value E<gt>= 0>.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::Primes>

=cut
