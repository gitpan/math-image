# Copyright 2010 Kevin Ryde

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

package App::MathImage::Values::RepdigitBase10;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 26;

use constant name => __('Repdigits Base 10');
use constant description => __('Numbers which are a "repdigit" in base 10, meaning 1 ... 9, 11, 22, 33, ... 99, 111, 222, 333, ..., 999, etc');

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { digit => -1,
                 reps  => 1,
               }, $class;
}
sub next {
  my ($self) = @_;
  if (++$self->{'digit'} > 9) {
    $self->{'digit'} = 1;
    $self->{'reps'}++;
  }
  return ($self->{'digit'} x $self->{'reps'});
}
sub pred {
  my ($self, $n) = @_;
  my $digit = substr($n,0,1);
  return ($n !~ /[^$digit]/);
}

1;
__END__
