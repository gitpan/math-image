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

package Math::NumSeq::MathImageSquareful;
use 5.004;
use strict;

use vars '$VERSION','@ISA';
$VERSION = 87;
use Math::NumSeq 7; # v.7 for _is_infinite()
@ISA = ('Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('Integers with a square factor k^2.');
use constant characteristic_increasing => 1;
use constant characteristic_integer => 1;
use constant values_min => 4;
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

# cf A001694 powerfuls p^k has k>=2
#    A168363 squares and cubes of primes, primitive powerfuls
#
my @oeis_anum;
$oeis_anum[2] = 'A013929'; # non squarefree, divisible by some p^2
$oeis_anum[3] = 'A046099'; # non cubefree, divisible by some p^3
$oeis_anum[4] = 'A046101'; # non 4th-free
sub oeis_anum {
  my ($self) = @_;
  ### $self
  return $oeis_anum[$self->{'power'}];
}

# each 2-bit vec() value is
#    0   unset
#    1   composite
#    2,3 square factor

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
  $self->{'done'} = 0;
  _restart_sieve ($self, 20);
}
sub _restart_sieve {
  my ($self, $hi) = @_;
  ### _restart_sieve() ...
  $self->{'hi'} = $hi;
  $self->{'string'} = "\0" x (($hi+1)/4);  # 4 of 2 bits each
  vec($self->{'string'}, 0,2) = 2;  # N=0 square
  vec($self->{'string'}, 1,2) = 1;  # N=1 composite
  # N=2,N=3 primes
}

sub next {
  my ($self) = @_;

  my $v = $self->{'done'};
  my $sref = \$self->{'string'};
  my $hi = $self->{'hi'};

  for (;;) {
    ### consider: "v=".($v+1)."  cf done=$self->{'done'}"
    if (++$v > $hi) {
      _restart_sieve ($self,
                      ($self->{'hi'} = ($hi *= 2)));
      $v = 2;
      ### restart to v: $v
    }

    my $vec = vec($$sref, $v,2);
    ### $vec
    if ($vec == 0) {
      ### prime: $v

      # composites
      for (my $j = 2*$v; $j <= $hi; $j += $v) {
        ### composite: $j
        vec($$sref, $j,2) |= 1;
      }
      # powers
      my $vpow = $v ** $self->{'power'};
      for (my $j = $vpow; $j <= $hi; $j += $vpow) {
        ### power: $j
        vec($$sref, $j,2) = 2;
      }
    }

    if ($vec >= 2 && $v > $self->{'done'}) {
      ### ret: $v
      $self->{'done'} = $v;
      return ($self->{'i'}++, $v);
    }
  }
}

sub pred {
  my ($self, $value) = @_;
  ### SquareFree pred(): $value

  if ($value < 4 || $value != int($value) || _is_infinite($value)) {
    return 0;
  }
  if ($value > 0xFFFF_FFFF) {
    return undef;
  }

  my $power = $self->{'power'};

  if (($value % 2) == 0) {
    $value /= 2;
    my $count = $power-1;
    while (($value % 2) == 0) {
      if (--$count <= 0) {
        return 1;  # power factor
      }
      $value /= 2;
    }
  }

  my $limit = $value ** (1/$power) + 1;
  my $p = 3;
  while ($p <= $limit) {
    if (($value % $p) == 0) {
      $value /= $p;
      my $count = $power-1;
      while (($value % $p) == 0) {
        if (--$count <= 0) {
          return 1;  # power factor
        }
        $value /= $p;
      }
      $limit = $value ** (1/$power) + 1;
      ### factor: "$p new limit $limit"
    }
    $p += 2;
  }
  return 0;
}

1;
__END__

=for stopwords Ryde Math-NumSeq

=head1 NAME

Math::NumSeq::MathImageSquareFree -- square free integers

=head1 SYNOPSIS

 use Math::NumSeq::MathImageSquareFree;
 my $seq = Math::NumSeq::MathImageSquareFree->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The square-free integers ...

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::MathImageSquareFree-E<gt>new ()>

Create and return a new sequence object.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is square-free.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::MobiusFunction>

=cut

# Local variables:
# compile-command: "math-image --values=Squareful"
# End:
