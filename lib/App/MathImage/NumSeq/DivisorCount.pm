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

package App::MathImage::NumSeq::DivisorCount;
use 5.004;
use strict;
use List::Util 'min', 'max';

use vars '$VERSION','@ISA';
$VERSION = 77;
use Math::NumSeq;
@ISA = ('Math::NumSeq');


# uncomment this to run the ### lines
#use Devel::Comments;


use constant description => Math::NumSeq::__('Count of prime factors.');
use constant characteristic_count => 1;
use constant characteristic_monotonic => 0;
use constant i_start => 1;

use constant parameter_info_array =>
  [ { name    => 'divisors_type',
      display => Math::NumSeq::__('Divisor Type'),
      type    => 'enum',
      choices => ['all','proper','propn1'],
      default => 'all',
      # description => Math::NumSeq::__(''),
    },
  ];


my %values_min = (all    => 1,
                  proper => 0,
                  propn1 => 0);
sub values_min {
  my ($self) = @_;
  return $values_min{$self->{'divisors_type'}};
}

# A000005
# A032741 - proper divisors 1<=d<n starting n=0
# A147588 - 
#
# A001227 - count odd divisors
# A001826 - count 4k+1 divisors
# A038548 - count divisors <= sqrt(n)
# A070824 - proper divisors starting n=2
# A002182 - new highest number of divisors
# A002183 - that number
#
# OEIS-Catalogue: A000005
# # OEIS-Catalogue: A001221 divisors_type=proper
# OEIS-Catalogue: A147588 divisors_type=propn1
my %oeis_anum = (all    => 'A000005',  # all divisors starting n=1
                 # proper => 'A032741', # starts n=0
                 propn1 => 'A147588'); # divisors 1<d<n starting n=1
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{$self->{'divisors_type'}};
}

sub rewind {
  my ($self) = @_;
  ### DivisorCount rewind()
  $self->{'i'} = 1;
  _restart_sieve ($self, 500);

  # while ($self->{'i'} < $self->{'lo'}-1) {
  #   ### rewind advance
  #   $self->next;
  # }
}
sub _restart_sieve {
  my ($self, $hi) = @_;

  $self->{'hi'} = $hi;
  $self->{'array'} = [ 0, (1) x $self->{'hi'} ];
}

sub next {
  my ($self) = @_;
  ### DivisorCount next() ...

  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));

  # my $hi = $self->{'hi'};
  # my $start = $i;
  # if ($i > $hi) {
  #   _restart_sieve ($self, $hi *= 2);
  #   $start = 2;
  # }
  # 
  # my $aref = \$self->{'array'};
  # ### $i
  # my $ret;
  # foreach my $i ($start .. $i) {
  #   $ret = $aref->[$i];
  #   if ($ret == 0 && $i >= 2) {
  #     $ret++;
  #     # a prime
  #     for (my $power = 1; ; $power++) {
  #       my $step = $i ** $power;
  #       last if ($step > $hi);
  #       for (my $j = $step; $j <= $hi; $j += $step) {
  #         $aref->[$j]++;
  #       }
  #       last if $self->{'divisors_type'} eq 'propn1';
  #     }
  #     # print "applied: $i\n";
  #     # for (my $j = 0; $j < $hi; $j++) {
  #     #   printf "  %2d %2d\n", $j, vec($$aref, $j,8));
  #     # }
  #   }
  # }
  # ### ret: "$i, $ret"
  # return ($i, $ret);
}

sub ith {
  my ($self, $i) = @_;

  if ($i < 0 || $i > 0xFFFF_FFFF) {
    return undef;
  }

  my $ret = 1;
  unless ($i % 2) {
    my $count = 1;
    do {
      $i /= 2;
      $count++;
    } until ($i % 2);
    $ret *= $count;
  }
  my $limit = sqrt($i);
  for (my $d = 3; $d <= $limit; $d+=2) {
    unless ($i % $d) {
      my $count = 1;
      do {
        $i /= $d;
        $count++;
      } until ($i % $d);
      my $limit = sqrt($i);
      $ret *= $count;
    }
  }
  if ($i > 1) {
    $ret *= 2;
  }
  if ($self->{'divisors_type'} eq 'propn1') {
    if ($ret <= 2) {
      return 0;
    }
    $ret -= 2;
  }
  return $ret;
}

sub pred {
  my ($self, $value) = @_;
  ### $self
  return ($value >= $values_min{$self->{'divisors_type'}}
          && $value == int($value));
}

1;
__END__

=for stopwords Ryde

=head1 NAME

Math::NumSeq::DivisorCount -- how many divisors

=head1 SYNOPSIS

 use Math::NumSeq::DivisorCount;
 my $seq = Math::NumSeq::DivisorCount->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The number of divisors of i, being 1,2,2,3,2,4,2, etc.

The sequence starts from i=1 and that 1 is divisible only by itself.  Then
i=2 is divisible by 1 and 2, then for instance 6 is divisible by 4 numbers
1,2,3,6.

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::DivisorCount-E<gt>new ()>

=item C<$seq = Math::NumSeq::DivisorCount-E<gt>new (divisors_type =E<gt> 'propn1')>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the number of prime factors in C<$i>.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs as a divisor count, which means simply
C<$value E<gt>= 2>.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PrimeFactorCount>

=cut
