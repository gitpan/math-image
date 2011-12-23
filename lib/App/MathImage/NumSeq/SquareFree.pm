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

package App::MathImage::NumSeq::SquareFree;
use 5.004;
use strict;

use vars '$VERSION','@ISA';
$VERSION = 86;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('The square-free integers, being those numbers without a square as a factor.');
use constant characteristic_increasing => 1;
use constant characteristic_integer => 1;
use constant values_min => 1;
use constant i_start => 1;

# cf A013929 the non-square-frees, 4,8,etc
#
use constant oeis_anum => 'A005117'; # 1,2,3,etc


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
      # squares
      my $vsquared = $v*$v;
      for (my $j = $vsquared; $j <= $hi; $j += $vsquared) {
        ### square: $j
        vec($$sref, $j,2) = 2;
      }

      # print "applied: $v\n";
      # for (my $j = 0; $j < $hi; $j++) {
      #   printf "  %2d %2d\n", $j, vec($$sref,$j,2);
      # }
    }

    if ($vec < 2 && $v > $self->{'done'}) {
      ### ret: $v
      $self->{'done'} = $v;
      return ($self->{'i'}++, $v);
    }
  }
}

sub pred {
  my ($self, $value) = @_;
  ### SquareFree pred(): $value
  if ($value < 0 || $value > 0xFFFF_FFFF) {
    return undef;
  }
  if ($value != int($value)) {
    return 0;
  }

  if (($value % 2) == 0) {
    $value /= 2;
    if (($value % 2) == 0) {
      return 0;  # square factor
    }
  }

  my $limit = int(sqrt($value));
  my $p = 3;
  while ($p <= $limit) {
    if (($value % $p) == 0) {
      $value /= $p;
      if (($value % $p) == 0) {
        return 0;  # square factor
      }
      $limit = int(sqrt($value));  # new smaller limit
      ### factor: "$p new limit $limit"
    }
    $p += 2;
  }
  return 1;
}

1;
__END__

=for stopwords Ryde Mobius ie Math-NumSeq

=head1 NAME

App::MathImage::NumSeq::SquareFree -- square free integers

=head1 SYNOPSIS

 use App::MathImage::NumSeq::SquareFree;
 my $seq = App::MathImage::NumSeq::SquareFree->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The square-free integers ...

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::SquareFree-E<gt>new ()>

Create and return a new sequence object.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is square-free.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::MobiusFunction>

=cut
