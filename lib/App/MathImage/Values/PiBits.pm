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

package App::MathImage::Values::PiBits;
use 5.004;
use strict;
use warnings;
use Carp;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 30;

use constant name => __('Pi Bits');
use constant description => __('Pi 3.141529... written out in binary.');

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $file = $options{'file'} || 'pi';

  require Compress::Zlib;
  my $dirname = List::Util::first {-e "$_/App/MathImage/$file.gz"} @INC
    or croak "Oops, $file.gz not found";
  my $gz = Compress::Zlib::gzopen("$dirname/App/MathImage/$file.gz", "r");

  return bless { gz => $gz,
                 n  => 0,
                 i  => 0,
                 buf => '',
               }, $class;
}
sub next {
  my ($self) = @_;

  if ($self->{'i'} >= length($self->{'buf'})) {
    if ($self->{'gz'}->gzread($self->{'buf'}) <= 0) {
      return;  # EOF
    }
    $self->{'i'} = 0;
  }
  return $self->{'n'} += ord(substr($self->{'buf'},$self->{'i'}++,1));
}

1;
__END__

