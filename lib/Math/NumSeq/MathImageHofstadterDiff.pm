# HofstadterRS ?




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

package Math::NumSeq::MathImageHofstadterDiff;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 93;

use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('Hofstadter diff sequence.');
use constant characteristic_increasing => 1;
use constant values_min => 1;
use constant i_start => 1;

# seq 1, 3, 7, 12,  18, 26, 35, 45, 56, 69, 83, 98, 114, 131, 150, 170, 191,
# diffs 2, 4, 5, 6,   8,  9,  10, 11, 13, 14, 15, 16,  17,  19,  20,  21, 22,

# A005228 - seq and first diffs make all integers, increasing
#  A030124 - the first diffs
#
# cf A061577 - starting from 2
#     A061578 - starting from 2 first diffs
#     2, 3, 7, 12, 18, 26, 35, 45,
#      1, 4, 5,  6,   8,  9, 10, 11, 13, 
#
#    A140778 - seq and first diffs make all positive integers,
#     each int applied to one of the two in turn
#      A140779 - its first diffs
#
#    A037257 - seq + first diffs + second diffs make all integers
#     A037258 - the first diffs
#     A037259 - the second diffs
#    A081145
#
use constant oeis_anum => 'A005228';


# start S
# S, S+1, S+2, ..., S+(S-1), S+(S+1), S+(S+2)

# $upto[0] is the previous value returned
# $inc[0] is the amount to increment it by next time
#
# $upto[1] is the sequence at a previous position
# if $inc[0] == $upto[1] then that increment must be skipped,
# and advance $upto[1] for the next to skip#
#
# initial
# upto[0] = 1
# inc[0] = 0
#
# return 1+0=1, small inc[0] -> 2
# upto[0] = 1
# inc[0] = 2
#
# return 1+2=3, small inc[0] -> 4
# upto[0] = 3
# inc[0] = 4
#
# return 3+4=7, small inc[0] 4 -> 5
# upto[0] = 7
# inc[0] = 5
#
# return 7+5=12, small inc[0] 5 -> 6
# upto[0] = 12
# inc[0] = 6
#
# return 12+6=18, small inc[0] 6 -> outside
# upto[0] = 12
# inc[0] = 8
# upto[1] = 12
# inc[1] = 6
#
# inc[0]==upto[1] so skip to inc[0]=4
# add 4 to return upto[0]=3+4=7
# $inc[0]++
# next upto[1] is 7
# upto[0] = 7
# upto[1] = 7
# inc[0] = 5
# inc[1] = 4
#
# add 7+5 to 12, inc[0]++
# upto[0] = 12
# upto[1] = 7
# inc[0] = 6
# inc[1] = 4
#
# add 12+6=18, inc[0]++
# upto[0] = 18
# upto[1] = 7
# inc[0] = 7
# inc[1] = 4
#
# inc[0]==upto[1] so skip to inc[0]=8
# add 8 to return upto[0]=18+8=26
# step upto[1] add inc[1]++ to 7+5=12
# upto[0] = 26
# upto[1] = 12
# inc[0] = 7
# inc[1] = 6
#

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
  $self->{'upto'} = [ 0, 7 ];
  $self->{'inc'}  = [ 1, 5 ];
}

# 1->2->4->5->6->7
#                    0  1  2    3    4  5  6
my @small_inc = (undef, 2, 4, undef, 5, 6, 7);

sub next {
  my ($self) = @_;
  ### HofstadterDiff next(): "$self->{'i'}"
  ### upto: join (', ',@{$self->{'upto'}})
  ### inc : join (', ',@{$self->{'inc'}})

  my $i = $self->{'i'}++;
  my $upto = $self->{'upto'};
  my $inc = $self->{'inc'};

  my $add = $inc->[0]++;
  if (defined (my $next_inc = $small_inc[$add])) {
    ### small next_inc: $next_inc
    $inc->[0] = $next_inc;

  } elsif ($add >= $upto->[1]) {
    ### must skip this increment ...
    ### add now: $inc->[0]
    $add = $inc->[0]++;

    # diff=26 already seen (6), at i=22 value=311 prev_value=285

    my $pos = 1;
    for (;;) {
      ### $pos
      if ($pos >= $#$upto) {
        ### grow ...
        push @$upto, 7;
        push @$inc, 5;
      }

      my $posadd = $inc->[$pos]++;
      ### $posadd
      $upto->[$pos] += $posadd;

      if (defined (my $next_inc = $small_inc[$posadd])) {
        ### small pos next_inc: $next_inc
        $inc->[$pos] = $next_inc;
        last;
      }
      if ($posadd < $upto->[$pos+1]) {
        ### less than next upto: $upto->[$pos+1]
        last;
      }
      $upto->[$pos]++; # skip and to next level
      $inc->[$pos]++;
      $pos++;
    }
  }
  ### $add
  ### for return value: $upto->[0] + $add
  return ($i,
          ($upto->[0] += $add));
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

Math::NumSeq::MathImageHofstadterDiff -- sequence excludes its own first differences

=head1 SYNOPSIS

 use Math::NumSeq::MathImageHofstadterDiff;
 my $seq = Math::NumSeq::MathImageHofstadterDiff->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is Douglas Hofstadter's R/S sequence which comprises all integers
except those which are the differences between its own successive values,

    1, 3, 7, 12, 18, 26, 35, 45, 56, 69, 83, 98, ...

So for example at value=1 the next cannot be 2 because the difference 2-1=1
is already in the sequence, so value=3 with difference 3-1=2 is next.  Then
the next cannot be 4 since 4-3=1 is already in the sequences, and likewise
5-3=2 and 6-3=3, so the next is value=7 with 7-3=4 not already in the
sequence.

The effect is that the sequence increments by 1,2,3,4, etc excluding values
of the sequence itself.  This makes it close to the Triangular numbers
i*(i+1)/2, but incrementing by a little extra at the places it skips its own
values.

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::MathImageHofstadterDiff-E<gt>new ()>

Create and return a new sequence object.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::Kolakoski>

=cut
