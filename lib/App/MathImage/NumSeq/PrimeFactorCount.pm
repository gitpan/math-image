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

package App::MathImage::NumSeq::PrimeFactorCount;
use 5.004;
use strict;
use List::Util 'min', 'max';

use Math::NumSeq;
use base 'Math::NumSeq';

use vars '$VERSION';
$VERSION = 69;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => Math::NumSeq::__('Count Prime Factors');
use constant description => Math::NumSeq::__('Count of prime factors.');
use constant characteristic_count => 1;
use constant characteristic_monotonic => 0;
use constant values_min => 1;
use constant i_start => 1;

use constant parameter_info_array => [ { name    => 'multiplicity',
                                         display => Math::NumSeq::__('Multiplicity'),
                                         type    => 'enum',
                                         choices => ['repeated','distinct'],
                                         default => 'repeated',
                                         # description => Math::NumSeq::__(''),
                                       },
                                     ];

# OEIS-Catalogue: A001221 multiplicity=distinct
# OEIS-Catalogue: A001222 multiplicity=repeated
my %oeis = (distinct => 'A001221',
            repeated => 'A001222');
sub oeis_anum {
  my ($self) = @_;
  return $oeis{$self->{'multiplicity'}};
}


sub rewind {
  my ($self) = @_;
  ### PrimeFactorCount rewind()

  my $hi = $self->{'hi'};
  $self->{'i'} = $self->i_start;
  $self->{'string'} = "\0" x ($self->{'hi'}+1);

  while ($self->{'i'} < $self->{'lo'}-1) {
    ### rewind advance
    $self->next;
  }
  return $self;
}

sub next {
  my ($self) = @_;
  ### PrimeFactorCount next()

  my $i = $self->{'i'}++;
  my $hi = $self->{'hi'};
  if ($i > $hi) {
    return;
  }
  my $cref = \$self->{'string'};
  ### $i

  my $ret = vec ($$cref, $i,8);
  if ($ret == 0 && $i >= 2) {
    $ret++;
    # a prime
    for (my $power = 1; ; $power++) {
      my $step = $i ** $power;
      last if ($step > $hi);
      for (my $j = $step; $j <= $hi; $j += $step) {
        vec($$cref, $j,8) = min (255, vec($$cref,$j,8)+1);
      }
      last if $self->{'multiplicity'} eq 'distinct';
    }
    # print "applied: $i\n";
    # for (my $j = 0; $j < $hi; $j++) {
    #   printf "  %2d %2d\n", $j, vec($$cref, $j,8));
    # }
  }
  ### ret: "$i, $ret"
  return ($i, $ret);
}

sub ith {
  my ($self, $i) = @_;
  ### PrimeFactorCount pred(): $i
  if ($self->{'i'} <= $i) {
    ### extend from: $self->{'i'}
    my $upto;
    while ((($upto) = $self->next)
           && $upto < $i) { }
  }
  return vec($self->{'string'}, $i,8);
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0);
}

1;
__END__



# Untouchables, not sum of proper divisors of any other integer
# p*q sum S=1+p+q
# so sums up to hi need factorize to (hi^2)/4
# 



=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::PrimeFactorCount -- how many prime factors

=head1 SYNOPSIS

 use App::MathImage::NumSeq::PrimeFactorCount;
 my $seq = App::MathImage::NumSeq::PrimeFactorCount->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The sequence of how many prime factors in i, being 0, 1, 1, 2, 1, 2, etc.

The sequence starts from i=1 and it's reckoned as 0 prime factors.  Then i=2
and i=3 are themselves primes, so 1 prime factor.  Then i=4 is 2*2 which is
2 prime factors.

The C<multiplicity> option can control whether repeats of a prime factors
are counted, or only distinct primes.  For example with "distinct" i=4 is
just 1 prime factor.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::PrimeFactorCount-E<gt>new ()>

=item C<$seq = App::MathImage::NumSeq::PrimeFactorCount-E<gt>new (multiplicity =E<gt> 'distinct')>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the number of prime factors in C<$i>.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value E<gt>= 0>, being possible counts of prime factors
which can occur in the sequence.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<App::MathImage::NumSeq::MobiusFunction>

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
