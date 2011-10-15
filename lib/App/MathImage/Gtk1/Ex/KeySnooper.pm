# Copyright 2008, 2009, 2010, 2011 Kevin Ryde

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

package App::MathImage::Gtk1::Ex::KeySnooper;
use 5.004;
use strict;
use warnings;

use vars '$VERSION';
$VERSION = 77;

sub new {
  my ($class, $func, $userdata) = @_;
  my $self = bless {}, $class;
  $self->install ($func, $userdata);
  return $self;
}

# not yet documented ...
sub install {
  my ($self, $func, $userdata) = @_;
  $self->remove;
  if ($func) {
    $self->{'id'} = Gtk->key_snooper_install ($func, $userdata);
  }
}

sub DESTROY {
  my ($self) = @_;
  $self->remove;
}

sub remove {
  my ($self) = @_;
  if (my $id = delete $self->{'id'}) {
    Gtk->key_snooper_remove ($id);
  }
}

1;
__END__
