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

package Math::NumSeq::MathImagePowerful;
use 5.004;
use strict;

use vars '$VERSION','@ISA';
$VERSION = 88;
use Math::NumSeq 7; # v.7 for _is_infinite()
use Math::NumSeq::Base::IteratePred;        
@ISA = ('Math::NumSeq::Base::IteratePred',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('Integers with a square factor k^2.');
use constant characteristic_increasing => 1;
use constant characteristic_integer => 1;
use constant i_start => 1;

use constant parameter_info_array =>
  [
   { name    => 'powerful_type',
     type    => 'enum',
     default => 'some',
     choices => ['some','all'],
     # description => Math::NumSeq::__(''),
   },
   { name    => 'power',
     type    => 'integer',
     default => '2',
     minimum => 2,
     width   => 2,
     # description => Math::NumSeq::__(''),
   },
  ];

sub values_min {
  my ($self) = @_;
  return ($self->{'powerful_type'} eq 'all'
          ? 1
          : 2 ** $self->{'power'});
}

# cf A168363 squares and cubes of primes, the primitives of "all" power=2
#
my %oeis_anum = (some => [undef,
                          undef,
                          'A013929', # 2 non squarefree, divisible by some p^2
                          'A046099', # 3 non cubefree, divisible by some p^3
                          'A046101', # 4 non 4th-free
                          # OEIS-Catalogue: A013929
                          # OEIS-Catalogue: A046099 power=3
                          # OEIS-Catalogue: A046101 power=4
                         ],
                 all  => [undef,
                          undef,
                          'A001694', # 2 all p^k has k >= 2
                          # OEIS-Catalogue: A001694 powerful_type=all
                         ],
                );
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{$self->{'powerful_type'}}->[$self->{'power'}];
}

# # each 2-bit vec() value is
# #    0   unset
# #    1   composite
# #    2,3 square factor
# 
# sub rewind {
#   my ($self) = @_;
#   $self->{'i'} = $self->i_start;
#   $self->{'done'} = 0;
#   _restart_sieve ($self, 20);
# }
# sub _restart_sieve {
#   my ($self, $hi) = @_;
#   ### _restart_sieve() ...
#   $self->{'hi'} = $hi;
#   $self->{'string'} = "\0" x (($hi+1)/4);  # 4 of 2 bits each
#   vec($self->{'string'}, 0,2) = 2;  # N=0 square
#   vec($self->{'string'}, 1,2) = 1;  # N=1 composite
#   # N=2,N=3 primes
# }
# 
# sub next {
#   my ($self) = @_;
# 
#   my $v = $self->{'done'};
#   my $sref = \$self->{'string'};
#   my $hi = $self->{'hi'};
# 
#   for (;;) {
#     ### consider: "v=".($v+1)."  cf done=$self->{'done'}"
#     if (++$v > $hi) {
#       _restart_sieve ($self,
#                       ($self->{'hi'} = ($hi *= 2)));
#       $v = 2;
#       ### restart to v: $v
#     }
# 
#     my $vec = vec($$sref, $v,2);
#     ### $vec
#     if ($vec == 0) {
#       ### prime: $v
# 
#       # composites
#       for (my $j = 2*$v; $j <= $hi; $j += $v) {
#         ### composite: $j
#         vec($$sref, $j,2) |= 1;
#       }
#       # powers
#       my $vpow = $v ** $self->{'power'};
#       for (my $j = $vpow; $j <= $hi; $j += $vpow) {
#         ### power: $j
#         vec($$sref, $j,2) = 2;
#       }
#     }
# 
#     if ($vec >= 2 && $v > $self->{'done'}) {
#       ### ret: $v
#       $self->{'done'} = $v;
#       return ($self->{'i'}++, $v);
#     }
#   }
# }

sub pred {
  my ($self, $value) = @_;
  ### SquareFree pred(): $value

  if ($value < 1 || $value != int($value) || _is_infinite($value)) {
    return 0;
  }
  if ($value > 0xFFFF_FFFF) {
    return undef;
  }

  my $power = $self->{'power'};
  my $limit = $value ** (1/$power) + 1;

  for (my $p = 2; $p <= $limit; $p += 2-($p==2)) {
    next if ($value % $p);
    ### prime factor: $p

    $value /= $p;
    my $count = $power-1;
    while (($value % $p) == 0) {
      if (--$count <= 0 && $self->{'powerful_type'} eq 'some') {
        return 1; # power factor
      }
      $value /= $p;
    }
    if ($self->{'powerful_type'} eq 'all' && $count > 0) {
      # p^k has k<$power, so not all factors suitable
      return 0;
    }

    $limit = $value ** (1/$power) + 1;
    ### divided out: "$p, new limit $limit"
  }

  ### final: $value
  return ($self->{'powerful_type'} eq 'all'
          && $value == 1);
}

1;
__END__

=for stopwords Ryde Math-NumSeq

=head1 NAME

Math::NumSeq::MathImagePowerful -- square free integers

=head1 SYNOPSIS

 use Math::NumSeq::MathImagePowerful;
 my $seq = Math::NumSeq::MathImagePowerful->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The square-free integers ...

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::MathImagePowerful-E<gt>new ()>

Create and return a new sequence object.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is ...

=back

=head1 SEE ALSO

L<Math::NumSeq>

=cut
