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


package App::MathImage::Wx::Params::Boolean;
use 5.004;
use strict;
use Wx;

use base 'Wx::CheckBox';
our $VERSION = 79;

sub new {
  my ($class, $parent, $info) = @_;
  ### Params-Boolean new(): "$parent"

  my $display = $info->{'display'};
  my $self = $class->SUPER::new ($parent,
                                 Wx::wxID_ANY(),
                                 defined $display ? $display : $info->{'name'});
  $self->SetValue ($info->{'default'});
  EVT_CHECKBOX ($self, 'OnCheckBoxClicked');
  return $self;
}

sub OnCheckBoxClicked {
  my ($self) = @_;
  ### OnCheckBoxClicked() ...
}

1;
__END__