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


# is_type('monotonic')
#    only by reading the whole file
#    assume seekable



package App::MathImage::NumSeq::Sequence::File;
use 5.004;
use strict;
use Carp;
use Fcntl;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 58;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('File');
use constant description => __('Numbers from a file');
use constant parameter_list =>
  ({
    name    => 'filename',
    type    => 'filename',
    display => __('Filename'),
    width   => 40,
    default => '',
   });

sub rewind {
  my ($self) = @_;
  ### NumSeq-File rewind()

  if ($self->{'fh'}) {
    seek $self->{'fh'}, 0, Fcntl::SEEK_SET() # parens because autoloaded ...
      or croak "Cannot rewind ",$self->{'filename'},": ",$!;
  } else {
    my $filename = $self->{'filename'};
    if (defined $filename && $filename !~ /^\s*$/) {
      my $fh;
      ($] >= 5.006
       ? open $fh, '<', $filename
       : open $fh, "< $filename")
        or croak "Cannot open ",$filename,": ",$!;
      $self->{'fh'} = $fh;
    }
  }
  $self->{'i'} = -1;
}

sub next {
  my ($self) = @_;
  my $fh = $self->{'fh'} || return;
  for (;;) {
    my $line = readline $fh;
    if (! defined $line) {
      return;
    }
    if ($line =~ /^\s*(-?\d+)(\s+(-?(\d+(\.\d*)?|\.\d+)))?/) {
      if (defined $3) {
        return ($self->{'i'} = $1, $3);
      } else {
        return (++$self->{'i'}, $1);
      }
    }
  }
}

1;
__END__
