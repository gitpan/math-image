# Copyright 2010, 2011, 2012 Kevin Ryde

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

package Math::NumSeq::MathImagePiBits;
use 5.004;
use strict;
use Carp;

use vars '$VERSION', '@ISA';
$VERSION = 95;
use Math::NumSeq;
@ISA = ('Math::NumSeq');


# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Pi Bits');
use constant description => Math::NumSeq::__('Pi 3.141529... written out in binary.');
use constant values_min => 0;
use constant characteristic_increasing => 1;

# A004601 to A004608 - base 2 to 9
# A000796 - base 10
# A068436 to A068440 - base 11 to 15
# A062964 - base 16
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
  my $i = $self->{'i'}++;
  return ($i, $self->{'n'} += ord(substr($self->{'buf'},$i,1)));
}

1;
__END__

