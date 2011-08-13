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


package App::MathImage::Prima::About;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';
use Prima; # constants
use Prima::Label;
use Prima::MsgBox;

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 66;

# use base 'Prima::Window';
# sub init {
#   my $self = shift;
#   ### About init: @_
#   my %profile = $self-> SUPER::init(@_);
# 
#   $self->insert
#     ('Label',
#      text  => __x('Math Image version {version}', version => $VERSION),
#     );
#   return %profile;
# }

sub popup {
  my $text = Prima::MsgBox::message
    (__x('Math Image version {version}', version => $VERSION)
     . "\n\n"
     . __x('Running under Prima {version}', version => Prima->VERSION),
     mb::Information() | mb::Ok());
}

1;
__END__
