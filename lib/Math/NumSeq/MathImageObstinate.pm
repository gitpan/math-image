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


# http://sprott.physics.wisc.edu/pickover/obstinate.html
#   127 then another 16 below 1000 --- not 1,3

# 1,
# 127, 149, 251, 331,
# 337, 373, 509, 599,
# 701, 757, 809, 877,
# 905, 907, 959, 977,
# 997, 

package Math::NumSeq::MathImageObstinate;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 87;
use Math::NumSeq;
@ISA = ('Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

use Math::NumSeq::Primes; # for primes_list()
use Math::Prime::XS 'is_prime';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('Odd numbers N not representable as prime+2^k.');
use constant values_min => 1;
use constant characteristic_increasing => 1;
use constant i_start => 1;

# odd not representable as prime+2^k
#
# cf A133122 -  # with k>0 so 1,3,127,...
#    A065381 - primes not p+2^k k>=0, reduce from odds to primes
#    
use constant oeis_anum => 'A006285'; # with k>=0 so 1,127,...


sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
  $self->{'string'} = '';
  # vec($self->{'string'},3/2,1) = 0;  # 2+2^0=3
  $self->{'done'} = -1;
  _resieve ($self, 20);
}

sub _resieve {
  my ($self, $hi) = @_;
  ### _resieve() ...

  $self->{'hi'} = $hi;
  my $sref = \$self->{'string'};
  vec($$sref,$hi,1) = 0;  # pre-extend
  my @primes = Math::NumSeq::Primes::_primes_list (3, $hi-1);
  for (my $power = 1; $power < $hi; $power *= 2) {
    foreach my $p (@primes) {
      if ((my $v = $p + $power) > $hi) {
        last;
      } else {
        vec($$sref,$v/2,1) = 1;
      }
    }
  }
}

sub next {
  my ($self) = @_;
  ### Obstinate next(): $self->{'i'}

  my $v = $self->{'done'};
  my $sref = \$self->{'string'};
  my $hi = $self->{'hi'};

  for (;;) {
    ### consider: "v=".($v+1)."  cf done=$self->{'done'}"
    if (($v+=2) > $hi) {
      _resieve ($self,
                $hi = ($self->{'hi'} *= 2));
    }
    unless (vec($$sref,$v/2,1)) {
      return ($self->{'i'}++,
              $self->{'done'} = $v);
    }
  }
}

sub pred {
  my ($self, $value) = @_;
  ### Obstinate pred(): $value

  if ($value == 3) {
    return 1;
  }
  if ($value != int($value)
      || _is_infinite($value)
      || $value < 1
      || ($value % 2) == 0) {
    return 0;
  }
  if ($value > 0xFFFF_FFFF) {
    return undef;
  }

  # Maybe an is_any_prime(...)
  for (my $power = 1; $power < $value; $power *= 2) {
    if (is_prime($value - $power)) {
      return 0;
    }
  }
  return 1;
}

1;
__END__

=for stopwords Ryde Math-NumSeq

=head1 NAME

Math::NumSeq::MathImageObstinate -- obstinate numbers, odd integers not of the form prime+2^k

=head1 SYNOPSIS

 use Math::NumSeq::MathImageObstinate;
 my $seq = Math::NumSeq::MathImageObstinate->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The obstinate numbers, being integers which cannot be represented as
prime+2^k for some prime and some power-of-2.

    1, 3, 127, 149, 251, ...

For example 149 is obstinate because none of 149-1, 149-2, 149-4,
... 149-128 are primes.

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::MathImageObstinate-E<gt>new ()>

=item C<$seq = Math::NumSeq::MathImageObstinate-E<gt>new (obstinate_type =E<gt> $str)>

Create and return a new sequence object.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is an obstinate, deficient or primitive obstinate per
C<$seq>.

This check requires factorizing C<$value> and in the current code a hard
limit of 2**32 is placed on values to be checked.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=cut
