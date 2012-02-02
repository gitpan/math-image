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


# David Madore  	  Oct 24 2004, 8:00 pm
# http://sci.tech-archive.net/Archive/sci.math.research/2004-10/0218.html


package Math::NumSeq::MathImageSieveMultiples;
use 5.004;
use strict;

use vars '$VERSION','@ISA';
$VERSION = 92;

use Math::NumSeq 7; # v.7 for _is_infinite()
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => Math::NumSeq::__('...');
use constant values_min => 1;
use constant i_start => 1;
use constant characteristic_smaller => 1;
use constant characteristic_integer => 1;

# 'A100002'
# 0  1  2  3  4  5  6  7  8  9
# 1, 2, 1, 2, 3, 3, 1, 2, 4, 4, 3, 4, 1, 2, 5, 5, 3, 5, 1, 2, 4, 5, 3, 4,
#             1  2        1  2

# cf A100287 - first occurrence of n
#
use constant oeis_anum => 'A100002';

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
  my $count = $self->{'count'} = [undef, [], []];
}
sub next {
  my ($self) = @_;
  ### SieveMultiples next(): $self->{'i'}

  my $count = $self->{'count'};
  ### $count

  my $value = 1;
  for my $level (2 .. $#$count) {
    ### $level
    ### $value
    ### count: ($count->[$level]->[$value]||0) + 1

    if (++$count->[$level]->[$value] >= $level) {
      $count->[$level]->[$value] = 0;
      $value = $level;
    }
  }

  if ($value >= $#$count-1) {
    push @$count, [ @{$count->[-1]} ];  # array copy
    ### extended to: $count
  }

  ### return: $value
  return ($self->{'i'}++,
          $value);
}

1;
__END__

=for stopwords Ryde

=head1 NAME

Math::NumSeq::MathImageSieveMultiples -- sieving of certain multiples

=head1 SYNOPSIS

 use Math::NumSeq::MathImageSieveMultiples;
 my $seq = Math::NumSeq::MathImageSieveMultiples->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is a sequence arising from a sieve replacing multiples, per
Sloane's OEIS A100002.

    1, 2, 1, 2, 3, 3, 1, 2, 4, 4, 3, 4, ...

The sieve begins with all 1s,

    1,1,1,1,1,1,1,1,1,1,1,1,...

Then every second 1 is changed to 2

    1,2,1,2,1,2,1,2,1,2,1,2,...

Then every third 1 is changed to 3, and every third 2 changed to 3,

    1,2,1,2,3,3,1,2,1,2,3,3,...

And every fourth 1, 2 and 3 likewise, etc.

    1,2,1,2,3,3,1,2,4,4,3,4,...

The replacing of every fourth (or whatever) is applied separately to the 1s,
2s, 3s etc in the sieve at that stage.

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::MathImageSieveMultiples-E<gt>new ()>

Create and return a new sequence object.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=cut
