# Copyright 2011, 2012 Kevin Ryde

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

package Math::NumSeq::MathImagePowerPart;
use 5.004;
use strict;

use vars '$VERSION','@ISA';
$VERSION = 89;
use Math::NumSeq 7; # v.7 for _is_infinite()
@ISA = ('Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('Largest square etc dividing i.');
use constant characteristic_non_decreasing => 0;
use constant characteristic_increasing => 0;
use constant characteristic_integer => 1;
use constant characteristic_smaller => 1;
use constant values_min => 1;
use constant i_start => 1;

use constant parameter_info_array =>
  [
   { name    => 'power',
     type    => 'integer',
     default => '2',
     minimum => 2,
     width   => 2,
     # description => Math::NumSeq::__(''),
   },
  ];

# cf A008833 - largest square dividing n
#    A008834 - largest cube dividing n
#    A008835 - largest 4th power dividing n
#
my @oeis_anum = (undef,
                 undef,
                 'A000188',  # 2 sqrt of largest square dividing n
                 'A053150',  # 3 cbrt of largest cube dividing n
                 'A053164',  # 4th root of largest 4th power dividing n
                 # OEIS-Catalogue: A000188
                 # OEIS-Catalogue: A053150 power=3
                 # OEIS-Catalogue: A053164 power=4
                );
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum[$self->{'power'}];
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
  _restart_sieve ($self, 20);
}
sub _restart_sieve {
  my ($self, $hi) = @_;
  ### _restart_sieve() ...
  $self->{'hi'} = $hi;
  my $array = $self->{'array'} = [];
  $#$array = $hi;
  $array->[1] = 1;
}

sub next {
  my ($self) = @_;

  my $i = my $target = $self->{'i'}++;
  if ($i > $self->{'hi'}) {
    _restart_sieve ($self, ($self->{'hi'} *= 2));
    $i = 2;
  }

  my $hi = $self->{'hi'};
  my $aref = $self->{'array'};

  my $ret;
  for ( ; $i <= $target; $i++) {
    $ret = $aref->[$i];
    if (! defined $ret) {
      ### prime: $i

      # composites marked
      for (my $j = 2*$i; $j <= $hi; $j += $i) {
        ### composite: $j
        $aref->[$j] ||= 1;
      }

      # square(etc) factors multiplied in
      my $pow = $i ** $self->{'power'};
      for (my $step = $pow; $step <= $hi; $step *= $pow) {
        ### $step
        for (my $j = $step; $j <= $hi; $j += $step) {
          ### divide: "j=$j value $aref->[$j] by $pow"
          $aref->[$j] *= $i;
        }
      }
    }
  }
  return ($target, $ret||1);
}

sub ith {
  my ($self, $i) = @_;
  ### PowerPart ith(): $i

  if (abs($i) > 0xFFFF_FFFF) {
    return undef;
  }
  if (_is_infinite($i)) {
    return $i;
  }
  if (abs($i) < 4) {
    return 1;
  }

  my $power = $self->{'power'};

  my $ret = 1;

  {
    my $pow = 2 ** $power;
    while (($i % $pow) == 0) {
      ### $pow
      $i /= $pow;
      $ret *= 2;
    }
    while (($i % 2) == 0) {
      $i /= 2;
    }
  }

  for (my $p = 3; ; $p += 2) {
    my $pow = $p ** $power;
    last if $pow > abs($i);
    while (($i % $pow) == 0) {
      ### $pow
      $i /= $pow;
      $ret *= $p;
    }
    while (($i % $p) == 0) {
      $i /= $p;
    }
  }

  ### $ret
  return $ret;
}

sub pred {
  my ($self, $value) = @_;
  return ($value == int($value) && $value >= 1);
}

1;
__END__

=for stopwords Ryde Math-NumSeq sqrt

=head1 NAME

Math::NumSeq::MathImagePowerPart -- largest square etc divisor

=head1 SYNOPSIS

 use Math::NumSeq::MathImagePowerPart;
 my $seq = Math::NumSeq::MathImagePowerPart->new (power => 2);
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The largest integer which square (etc) is a divisor of i.

    1, 1, 1, 2, 1, 1, 1, 2, 3, ...

For example at i=27 the power part is 3 since 3^2=9 is the largest which,
when squared, is a divisor of 27.

The C<power> parameter selects what power divisor is sought.  For example
C<power=E<gt>3> finds the largest cube dividing i.

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::MathImagePowerPart-E<gt>new ()>

=item C<$seq = Math::NumSeq::MathImagePowerPart-E<gt>new (power =E<gt> $integer)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the largest perfect square, cube, etc dividing C<$i>.

The current code relies on factorizing C<$i> and a hard limit of 2**32 is
placed on C<$i> in the interests of not going into a near-infinite loop.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs in the sequence, which is simply any integer
C<$value> E<gt>= 1.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::MobiusFunction>

=cut
