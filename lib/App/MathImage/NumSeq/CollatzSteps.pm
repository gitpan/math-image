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

package App::MathImage::NumSeq::CollatzSteps;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;

use App::MathImage::NumSeq '__';
use App::MathImage::NumSeq::Base::IterateIth;
@ISA = ('App::MathImage::NumSeq::Base::IterateIth',
        'App::MathImage::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => __('Number of steps to reach 1 in the Collatz "3n+1" problem.');
use constant characteristic_count => 1;
use constant values_min => 1;
use constant i_start => 1;

use constant parameter_list =>
  ({ name    => 'step_type',
     display => __('Step Type'),
     type    => 'enum',
     default => 'up',
     choices => ['up','down','both'],
     description => __('Which steps to count, the 3*n+1 ups, the n/2 downs, or both.'),
   });

# cf
#    A075680 odd numbers only
#    A008908 count of both halvings and triplings, with +1
#
my %step_type_to_anum = (up   => 'A006667', # triplings
                         down => 'A006666', # halvings
                         both => 'A006577', # both halvings and triplings
                        );
sub oeis_anum {
  my ($self) = @_;
  return $step_type_to_anum{$self->{'step_type'}};
}
# OEIS-Catalogue: A006667 step_type=up
# OEIS-Catalogue: A006666 step_type=down
# OEIS-Catalogue: A006577 step_type=both

my %step_type_to_up = (up   => 1,
                       down => 0,
                       both => 1);
my %step_type_to_down = (up   => 0,
                         down => 1,
                         both => 1);
sub ith {
  my ($self, $i) = @_;
  ### CollatzSteps ith(): $i
  my $count = 0;
  if ($i <= 1) {
    return $count;
  }
  my $step_type = $self->{'step_type'};
  my $count_up = $step_type_to_up{$step_type};
  my $count_down = $step_type_to_down{$step_type};
  for (;;) {
    until ($i & 1) {
      $i >>= 1;
      $count += $count_down;
    }
    ### odd: $i
    if ($i <= 1) {
      return $count;
    }
    $i = 3*$i + 1;
    $count += $count_up;
    ### tripled: "$i  count=$count"
  }
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0);
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::CollatzSteps -- steps in the "3n+1" problem

=head1 SYNOPSIS

 use App::MathImage::NumSeq::CollatzSteps;
 my $seq = App::MathImage::NumSeq::CollatzSteps->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The number of steps it takes to reach 1 by the Collatz "3n+1" problem,

    n -> / 3n+1  if n odd
         \ n/2   if n even

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::CollatzSteps-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the number of steps to take C<$i> down to 1.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs as a step count.  This is true for any
non-negative C<$value>.

=back

=head1 SEE ALSO

L<App::MathImage::NumSeq>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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
