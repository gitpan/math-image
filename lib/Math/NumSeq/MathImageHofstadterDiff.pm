# triangular with some skipping ...



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
$VERSION = 91;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => Math::NumSeq::__('Hofstadter diff sequence.');
use constant characteristic_increasing => 1;
use constant values_min => 1;
use constant i_start => 1;

# cf A030124 - the differences, being the complement seq
#    A061577 - starting from 2
#    A061578 - starting from 2 differences
# A140778 
# A037257, A037258, A037259 - first and second diffs disjoint
#
use constant oeis_anum => 'A005228';

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 1;
  $self->{'prev'} = 0;
  $self->{'diff_upto'} = 0;
  $self->{'diff_exclude'} = {};

  $self->{'upto'} = [ 1, 1 ];
  $self->{'inc'} = [ 0 ];
}

sub next {
  my ($self) = @_;
  ### HofstadterDiff next(): "$self->{'i'}"
  ### upto: $self->{'upto'}->[0]
  ### inc: $self->{'inc'}->[0]
  ### next skip inc: $self->{'upto'}->[1]
  ### assert: $self->{'inc'}->[0] < $self->{'upto'}->[1]

  # if ($self->{'i'}++ == 1) {
  #   return (1,1);
  # }
  # 
  # my $upto = $self->{'upto'};
  # my $inc = $self->{'inc'};
  # my $add = ++$inc->[0];
  # if ($add == $upto->[1]) {
  #   ### must skip: $add
  #   $add = ++$inc->[0];
  # 
  #   my $pos = 1;
  #   for (;;) {
  #     if ($pos > $#$inc) {
  #       $upto->[$pos] = 1;
  #       $inc->[$pos] = 1;
  #       $upto->[$pos+1] = 3;
  #       ### extend ...
  #       ### $upto
  #       ### $inc
  #       last;
  #     }
  # 
  #     ### $pos
  #     ### upto: $self->{'upto'}->[$pos]
  #     ### inc: $self->{'inc'}->[$pos]
  #     ### next skip inc: $self->{'upto'}->[$pos+1]
  #     ### assert: $self->{'inc'}->[$pos] < $self->{'upto'}->[$pos+1]
  # 
  #     my $subadd = ++$inc->[$pos];
  #     $upto->[$pos] += $subadd;
  #     if ($subadd == $upto->[$pos+1]) {
  #       ### must skip subadd: $subadd
  #       $inc->[$pos]++;
  #       $upto->[$pos]++;
  #       $pos++;
  #     } else {
  #       last;
  #     }
  #   }
  # }
  # ### $add
  # return ($self->{'i'}++, $upto->[0] += $add);



  ### diff_exclude size: scalar(my @x = values %{$self->{'diff_exclude'}})

  my $diff = $self->{'diff_upto'};
  my $diff_exclude = $self->{'diff_exclude'};
  while (delete $diff_exclude->{++$diff}) {
    ### exclude: $diff
  }
  my $ret = $self->{'prev'} + $diff;
  $self->{'diff_upto'} = $diff;
  $self->{'prev'} = $ret;
  $diff_exclude->{$ret} = 1;
  return ($self->{'i'}++, $ret);
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

...

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::MathImageHofstadterDiff-E<gt>new ()>

Create and return a new sequence object.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::Kolakoski>

=cut
