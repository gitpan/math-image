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

package App::MathImage::NumSeq::OeisCatalogue::Base;
use 5.004;
use strict;

use vars '$VERSION';
$VERSION = 57;

# uncomment this to run the ### lines
#use Smart::Comments;

my %anum_to_info_hashref;
sub anum_to_info_hashref {
  my ($class) = @_;
  ### anum_to_info_hashref(): $class
  return ($anum_to_info_hashref{$class} ||=
          { map { $_->{'anum'} => $_ } @{$class->info_arrayref} });
}

sub anum_to_info {
  my ($class, $anum) = @_;
  return $class->anum_to_info_hashref->{$anum};
}

sub anum_after {
  my ($class, $after_anum) = @_;
  ### $after_anum
  my $ret;
  foreach my $info (@{$class->info_arrayref}) {
    ### after info: $info
    if ($info->{'anum'} gt $after_anum
        && (! defined $ret || $ret gt $info->{'anum'})) {
      $ret = $info->{'anum'};
    }
  }
  return $ret;
}
sub anum_before {
  my ($class, $before_anum) = @_;
  ### $before_anum
  my $ret;
  foreach my $info (@{$class->info_arrayref}) {
    if ($info->{'anum'} lt $before_anum
        && (! defined $ret || $ret lt $info->{'anum'})) {
      $ret = $info->{'anum'};
    }
  }
  return $ret;
}

sub anum_first {
  my ($class, $after_num) = @_;
  return $class->anum_after('A000000');
}
sub anum_last {
  my ($class, $before_num) = @_;
  return $class->anum_before('A1000000');
}

1;
__END__

