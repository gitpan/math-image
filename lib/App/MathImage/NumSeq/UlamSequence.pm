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

package App::MathImage::NumSeq::UlamSequence;
use 5.004;
use strict;

use vars '$VERSION','@ISA';
$VERSION = 78;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;


use constant description => Math::NumSeq::__('Ulam sequence, 1,2,3,4,6,8,11,etc starting 1,2 then each member being uniquely representable as the sum of two earlier values.');
use constant characteristic_monotonic => 2;
use constant values_min => 1;

use constant parameter_info_array =>
  [
   { name    => 'start_values',
     display => Math::NumSeq::__('Start Values'),
     type    => 'string',
     default => '1,2',
     choices => ['1,2', '1,3', '1,4', '1,5',
                 '2,3', '2,4', '2,5'],
     description => Math::NumSeq::__('Starting values for the sequence.'),
   },
  ];

my %oeis_anum = ('1,2' => 'A002858',
                 '1,3' => 'A002859',
                 '1,4', => 'A003666',
                 '1,5', => 'A003667',
                 '2,3', => 'A001857',
                 '2,4', => 'A048951',
                 '2,5', => 'A007300',

                  # OEIS-Catalogue: A002858 start_values=1,2
                  # OEIS-Catalogue: A002859 start_values=1,3
                  # OEIS-Catalogue: A003666 start_values=1,4
                  # OEIS-Catalogue: A003667 start_values=1,5
                  # OEIS-Catalogue: A001857 start_values=2,3
                  # OEIS-Catalogue: A048951 start_values=2,4
                  # OEIS-Catalogue: A007300 start_values=2,5
                );
sub oeis_anum {
  my ($self) = @_;
  (my $key = $self->{'start_values'}) =~ tr/ \t//d;
  return $oeis_anum{$key};
}
  
# each 2-bit vec() value is
#    0 not a sum
#    1 sum one
#    2 sum two or more
#    3 (unused)

my @transform = (0, 0, 1, -1);

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 1;
  $self->{'upto'} = 0;
  $self->{'string'} = "\x14";  # N=1,N=2 members
}

# 0 => 1,
# 1 => 2,
# 2 => 2);
my @incr = (1,2,2);

sub next {
  my ($self) = @_;

  my $upto = $self->{'upto'};
  my $sref = \$self->{'string'};

  for (;;) {
    $upto++;
    my $entry = vec($$sref, $upto,2);
    ### $upto
    ### $entry
    if ($entry == 1) {
      foreach my $i (1 .. $upto-1) {
        if (vec($$sref, $i,2) == 1) {
          vec($$sref, $i+$upto,2) = $incr[vec($$sref, $i+$upto,2)];
        }
      }
      return ($self->{'i'}++, ($self->{'upto'} = $upto));
    }
  }
}

1;
__END__

# Local variables:
# compile-command: "math-image --values=UlamSequence"
# End:
