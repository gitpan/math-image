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

package App::MathImage::ValuesFile;
use 5.006;
use strict;
use warnings;

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 43;

# uncomment this to run the ### lines
#use Smart::Comments;

our %filetemp;

# return object, or undef if cannot satisfy requested 'hi'
sub new {
  my $class = shift;
  ### ValuesFile new(): @_
  my $self = bless { @_ }, $class;

  my $package = $self->{'package'};
  my $options = $self->{'options'};
  if (defined $options) {
    $options = "--$options";
  } else {
    $options = '';
  }
  my $key = "$package--$options";

  if (my $filetemp = $filetemp{$key}) {
    ### filename: $filetemp->filename
    if (open my $fh, '<', $filetemp->filename) {
      if (my ($hi) = <$fh>) {
        chomp $hi;
        ### $hi
        if ($hi >= $self->{'hi'}) {
          $self->{'hi'} = $hi;
          $self->{'fh'} = $fh;
          my $bytes = ($hi+1 + 7) >> 3;
          seek $fh, 32+1+$bytes, 0 or die;
          ### $self
          return $self;
        }
      }
    }
  }
  return undef;
}

sub next {
  my ($self) = @_;
  ### ValuesFile next(): $self
  if (defined (my $n = readline ($self->{'fh'}))) {
    chomp $n;
    return $n;
  } else {
    return;
  }
}

sub pred {
  my ($self, $n) = @_;
  my $pos = 32 + ($n>>3);
  seek $self->{'fh'}, $pos, 0;
  read $self->{'fh'}, my $buf, 1 or die;
  return vec($buf, $n&7,1);
}

sub name            { return $_[0]->{'package'}->name        }
sub type            { return $_[0]->{'package'}->type        }
sub description     { return $_[0]->{'package'}->description }
sub parameter_list  { return $_[0]->{'package'}->parameter_list  }
sub parameter_hash  { return $_[0]->{'package'}->parameter_hash  }
sub density         { return $_[0]->{'package'}->density     }


1;
__END__
