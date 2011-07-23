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


package Math::PlanePath::MathImageFile;
use 5.004;
use strict;
use Carp;
use POSIX 'floor';

use vars '$VERSION', '@ISA';
$VERSION = 65;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Devel::Comments;

sub n_start    { return _read($_[0])->{'n_start'} }
sub x_negative { return _read($_[0])->{'x_negative'} }
sub y_negative { return _read($_[0])->{'y_negative'} }
sub figure     { return _read($_[0])->{'figure'} }

sub n_to_xy {
  my ($self, $n) = @_;
  if (defined (my $x = _read($self)->{'x_array'}->[$n])) {
    return ($x, $self->{'y_array'}->[$n]);
  }
  return;
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  # lazy xy_hash creation
  if (! defined $self->{'xy_hash'}) {
    my %xy_hash;
    _read($self)->{'xy_hash'} = \%xy_hash;
    my $x_array = $self->{'x_array'};
    my $y_array = $self->{'y_array'};
    for (my $n = 0; $n <= $#$x_array; $n++) {
      if (defined (my $nx = $x_array->[$n])) {
        $xy_hash{"$nx,$y_array->[$n]"} = $n;

        #  && $nx == int($nx)
        # if ($ny == int($ny)) {
        # }
      }
    }
  }

  {
    my $key;
    if ($self->{'figure'} eq 'square') {
      $key = floor($x + 0.5).','.floor($y + 0.5);
    } else {
      $key = "$x,$y";
    }
    if (defined (my $n = _read($self)->{'xy_hash'}->{$key})) {
      return $n;
    }
  }

  my $x_array = $self->{'x_array'};
  my $y_array = $self->{'y_array'};
  for (my $n = 0; $n <= $#$x_array; $n++) {
    defined (my $nx = $x_array->[$n]) or next;
    my $ny = $y_array->[$n];
    if (($x-$nx)**2 + ($y-$ny)**2 <= .25) {
      return $n;
    }
  }
  return undef;
}

sub rect_to_n_range {
  my ($self) = @_;
  _read($self);
  return ($self->{'n_start'}, $self->{'n_last'});
}

my $num = "-?(?:\\.[0-9]+|[0-9]+(?:\\.[0-9]*)?)(?:[eE]-?[0-9]+)?";

sub _read {
  my ($self) = @_;
  if (defined $self->{'n_start'}) {
    return $self;
  }

  my $n = 1;
  $self->{'n_start'} = $n;
  $self->{'n_last'} = $n-1;    # default no range
  $self->{'x_negative'} = 0;
  $self->{'y_negative'} = 0;
  $self->{'figure'} = 'square';

  my $filename = $self->{'filename'};
  if (! defined $filename || $filename =~ /^\s*$/) {
    return $self;
  }
  my $fh;
  ($] >= 5.006
   ? open $fh, '<', $filename
   : open $fh, "< $filename")
    or croak "Cannot open ",$filename,": ",$!;

  my $n_start;
  my @x_array;
  my @y_array;
  my $x_negative = 0;
  my $y_negative = 0;
  my $any_frac = 0;
  while (my $line = <$fh>) {
    $line =~ /^\s*-?\.?[0-9]/
      or next;
    $line =~ /^\s*($num)[ \t,]+($num)([ \t,]+($num))?/o
      or do {
        warn $filename,':',$.,": MathImageFile unrecognised line: ",$line;
        next;
      };
    my ($x,$y);
    if (defined $4) {
      $n = $1;
      $x = $2;
      $y = $4;
    } else {
      $x = $1;
      $y = $2;
    }
    $x_array[$n] = $x;
    $y_array[$n] = $y;
    $x_negative ||= ($x < 0);
    $y_negative ||= ($y < 0);
    $any_frac ||= ($x != int($x) || $y != int($y));
    if (! defined $n_start || $n < $n_start) { $n_start = $n; }
    ### $x
    ### $y
    $n++;
  }

  close $fh
    or croak "Error closing ",$filename,": ",$!;

  $self->{'x_array'} = \@x_array;
  $self->{'y_array'} = \@y_array;
  $self->{'x_negative'} = $x_negative;
  $self->{'y_negative'} = $y_negative;
  $self->{'n_start'} = $n_start;
  $self->{'n_last'} = $#x_array; # last n index
  if ($any_frac) { $self->{'figure'} = 'circle' }
  return $self;
}

1;
__END__

=for stopwords Ryde

=head1 NAME

Math::PlanePath::MathImageFile -- points from a file

=head1 SYNOPSIS

 use Math::PlanePath::MathImageFile;
 my $path = Math::PlanePath::MathImageFile->new (filename => 'foo.txt');
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<Experimental.>

This path reads X,Y points from a file to present in PlanePath style.  The
intention is to be flexible about the file format and to auto-detect the
format as far as possible.  Currently the only format is plain text, with an
X,Y pair, or N,X,Y triplet on each line

    5, 6                  # X,Y
    123  5 6              # N,X,Y

Separators can be any combination of spaces, tabs, commas.  Blank lines or
lines not starting with a number are ignored as comments.  N values must be
integers, but the X,Y can be floating point style 1500.5e-1 etc too.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageFile-E<gt>new (filename =E<gt> "/my/file/name.txt")>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.

In the current code an C<$x,$y> within a unit diameter circle of a point
from the file gives that point.

=item C<$bool = $path-E<gt>x_negative()>

=item C<$bool = $path-E<gt>y_negative()>

Return true if there are any negative X or negative Y coordinates in the
file, respectively.

=item C<$n = $path-E<gt>n_start()>

Return the first N in the path.  For X,Y data lines the start is N=1, for
N,X,Y data it's the smallest N.

=back

=head1 SEE ALSO

L<Math::PlanePath>

=cut
