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

package App::MathImage::NumSeq::Harshad;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;

use App::MathImage::NumSeq '__';
use App::MathImage::NumSeq::Base::IteratePred;
@ISA = ('App::MathImage::NumSeq::Base::IteratePred',
        'App::MathImage::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('Harshad Numbers');
use constant description => __('Harshad numbers, divisible by the sum of their digits.');
use constant values_min => 1;
use constant i_start => 1;

use App::MathImage::NumSeq::Base::Digits;
use constant parameter_list =>
  (App::MathImage::NumSeq::Base::Digits::parameter_common_radix);

my %oeis = (2  => 'A049445',  # binary 1s divide N
            10 => 'A005349',  # decimal sum digits divide N
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis{$radix};
}
# OEIS-Catalogue: A049445 radix=2
# OEIS-Catalogue: A005349 radix=10

sub pred {
  my ($self, $value) = @_;
  ### Harshad pred(): $value
  if ($value <= 0) {
    return 0;
  }
  my $radix = $self->{'radix'};
  my $sum = 0;
  my $v = $value;
  while ($v) {
    $sum += ($v % $radix);
    $v = int($v/$radix);
  }
  return ! ($value % $sum);
}
# sub ith {
#   my ($self, $i) = @_;
#   return ...
# }

1;
__END__

=for stopwords Ryde MathImage harshad ie

=head1 NAME

App::MathImage::NumSeq::Harshad -- harshad numbers

=head1 SYNOPSIS

 use App::MathImage::NumSeq::Harshad;
 my $seq = App::MathImage::NumSeq::Harshad->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The harshad numbers, sometimes called Niven numbers, being integers which
are divisible by the sum of their digits

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::Harshad-E<gt>new (key=E<gt>value,...)>

=item C<$seq = App::MathImage::NumSeq::Harshad-E<gt>new (radix =E<gt> $r)>

Create and return a new sequence object.  The optional C<radix> parameter
(default 10, decimal) sets the base to use for the digits.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is a harshad number, ie. is divisible by the sum of
its digits (in the radix of C<$seq>).

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
