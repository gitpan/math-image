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

package App::MathImage::NumSeq::Woodall;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;

use App::MathImage::NumSeq '__';
use App::MathImage::NumSeq::Base::IterateIth;
@ISA = ('App::MathImage::NumSeq::Base::IterateIth',
        'App::MathImage::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('Woodall');
use constant description => __('Woodall numbers n*2^n-1.');
use constant values_min => 1;
use constant i_start => 1; # from 1*2^1-1==1

# cf A002234 - Woodall primes
#    A050918 - n for the Woodall primes
#    A056821 - totient(woodall)
use constant oeis_anum => 'A003261';

sub ith {
  my ($self, $i) = @_;
  return $i * 2**$i - 1;
}

sub pred {
  my ($self, $value) = @_;
  ### Woodall pred(): $value
  ($value >= 1 && $value & 1) or return 0;
  my $exp = 0;
  $value += 1;  # now seeking $value == $exp * 2**$exp
  for (;;) {
    if ($value <= $exp || $value & 1) {
      return ($value == $exp);
    }
    $value >>= 1;
    $exp++;
  }
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::Woodall -- Woodall numbers n*2^n-1

=head1 SYNOPSIS

 use App::MathImage::NumSeq::Woodall;
 my $seq = App::MathImage::NumSeq::Woodall->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The Woodall numbers 1, 7, 23, 63, etc, n*2^n-1 starting from n=1.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::Woodall-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return C<$i * 2**$i - 1>.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is a Woodall number, ie. is equal to n*2^n-1 for
some n.

=back

=head1 SEE ALSO

L<App::MathImage::NumSeq>,
L<App::MathImage::NumSeq::Cullen>,
L<App::MathImage::NumSeq::Proth>

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
