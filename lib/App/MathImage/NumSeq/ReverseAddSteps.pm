# count of 1 always ?
# hard limit on steps ?





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

package App::MathImage::NumSeq::ReverseAddSteps;
use 5.004;
use strict;
use POSIX 'ceil';
use List::Util 'max';

use vars '$VERSION','@ISA';
$VERSION = 72;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

# use constant name => Math::NumSeq::__('Reverse Add Steps');
use constant description => Math::NumSeq::__('How many steps of reverse and add until a palindrome is reached, sometimes called the 196-algorithm.');
use constant characteristic_count => 1;
use constant characteristic_monotonic => 0;
use constant values_min => 0;
use constant i_start => 0;

use Math::NumSeq::Base::Digits;
use constant parameter_info_array =>
  [ Math::NumSeq::Base::Digits::parameter_common_radix() ];

my @oeis_anum;
$oeis_anum[10] = 'A030547';
# OEIS-Catalogue: A030547 radix=10
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum[$self->{'radix'}];
}

sub rewind {
  my ($self) = @_;
  require Math::BigInt;
  Math::BigInt->import (try => 'GMP');
  $self->{'i'} = max(0,$self->{'lo'});
}
sub next {
  my ($self) = @_;
  ### ReverseAddSteps next(): $self->{'i'}
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}
sub ith {
  my ($self, $k) = @_;
  ### ReverseAddSteps ith(): $k
  my $radix = $self->{'radix'};

  # $k = Math::BigInt->new($k);
  my $count = 1;
 OUTER: for ( ; $count < 30; $count++) {
    my @digits;
    ### $count
    ### k: "$k"

    if (ref $k) {
      my $d = $k->copy;
      while ($d) {
        push @digits, $d % $radix;
        $d->bdiv($radix);
      }
      ### big digits: join(',',@digits)

      for my $i (0 .. int(@digits/2)-1) {
        if ($digits[$i] != $digits[-1-$i]) {
          ### not a palindrome ...

          foreach my $i (0 .. $#digits) {
            $d->bmul($radix);
            $d->badd($digits[$i]);
          }
          ### k: "$k"
          ### d: "$d"
          $k += $d;
          ### sum now: "$k"
          next OUTER;
        }
      }
    } else {
      my $d = $k;
      while ($d) {
        push @digits, $d % $radix;
        $d = int($d/$radix);
      }
      ### small digits: join(',',@digits)

      for my $i (0 .. int(@digits/2)-1) {
        if ($digits[$i] != $digits[-1-$i]) {
          ### not a palindrome ...

          if (@digits >= 10) {
            $d = Math::BigInt->bzero;
          }
          foreach my $i (0 .. $#digits) {
            $d *= $radix;
            $d += $digits[$i];
          }
          ### k: "$k"
          ### d: "$d"
          $k += $d;
          ### sum now: "$k"
          next OUTER;
        }
      }
    }
    # palindrome
    last;
  }
  ### return: $count
  return $count;
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0);
}

1;
__END__

=for stopwords Ryde Math-NumSeq

=head1 NAME

App::MathImage::NumSeq::ReverseAddSteps -- steps of the reverse-add algorithm

=head1 SYNOPSIS

 use App::MathImage::NumSeq::ReverseAddSteps;
 my $seq = App::MathImage::NumSeq::ReverseAddSteps->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The number of steps to reach a palindrome by the digits "reverse and add"
algorithm.  For example the i=19 is 3 because 19+91=110, then 110+011=121

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::ReverseAddSteps-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the number of reverse-add steps required to reach a palindrome.  For
some numbers this is very large and conjectured to be infinite, so in the
current code a limit of 30 is imposed.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value E<gt>= 0>, since any count of steps is possible.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::Cubes>

=cut
