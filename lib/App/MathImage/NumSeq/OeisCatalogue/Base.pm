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
$VERSION = 48;

# uncomment this to run the ### lines
#use Smart::Comments;

my %num_to_info_hashref;
sub num_to_info_hashref {
  my ($class) = @_;
  return ($num_to_info_hashref{$class} ||=
          { map { $_->{'num'} => $_ } @{$class->info_arrayref} });
}

sub num_to_info {
  my ($class, $num) = @_;
  return $class->num_to_info_hashref->{$num};
}

sub num_after {
  my ($class, $after_num) = @_;
  my $ret;
  foreach my $info (@{$class->info_arrayref}) {
    if ($info->{'num'} > $after_num
        && (! defined $ret || $ret > $info->{'num'})) {
      $ret = $info->{'num'};
    }
  }
  return $ret;
}
sub num_before {
  my ($class, $before_num) = @_;
  my $ret;
  foreach my $info (@{$class->info_arrayref}) {
    if ($info->{'num'} < $before_num
        && (! defined $ret || $ret < $info->{'num'})) {
      $ret = $info->{'num'};
    }
  }
  return $ret;
}

sub num_first {
  my ($class, $after_num) = @_;
  return $class->num_after(-1);
}
sub num_last {
  my ($class, $before_num) = @_;
  return $class->num_before(999_999_999);
}

1;
__END__

