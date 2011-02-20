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

package App::MathImage::Values::OEIS::Catalogue;
use 5.004;
use strict;
use Module::Pluggable require => 1;

use vars '$VERSION';
$VERSION = 44;

# uncomment this to run the ### lines
#use Smart::Comments;

sub num_to_info {
  my ($class, $num) = @_;
  foreach my $plugin ($class->plugins) {
    ### $plugin
    if (my $info = $plugin->num_to_info($num)) {
      return $info;
    }
  }
  return undef;
}

sub num_list {
  my ($class, $num) = @_;
  my %ret;
  foreach my $plugin ($class->plugins) {
    ### $plugin
    foreach my $info (@{$plugin->info_arrayref}) {
      $ret{$info->{'num'}} = 1;
    }
  }
  my @ret = sort {$a<=>$b} keys %ret;
  return @ret;
}

sub num_after {
  my ($class, $after_num) = @_;
  foreach my $num ($class->num_list) {
    if ($num > $after_num) {
      return $num;
    }
  }
  return undef;
}
sub num_before {
  my ($class, $before_num) = @_;
  my $ret;
  foreach my $num ($class->num_list) {
    if ($num < $before_num) {
      $ret = $num;
    } else {
      last;
    }
  }
  return $ret;
}



# sub anum_to_class {
#   my ($class, $anum) = @_;
#   ### anum_to_class(): @_
#   my @ret;
#   foreach my $plugin ($class->plugins) {
#     ### $plugin
#     my $href = $plugin->anum_to_class_hashref;
#     if (my $aref = $href->{$anum}) {
#       return @$aref;
#     }
#   }
#   return;
# }
# 
# sub _file_anum_list {
#   my ($class) = @_;
#   ### anum_list()
#   my %ret;
#   foreach my $plugin ($class->plugins) {
#     ### $plugin
#     my $href = $plugin->anum_to_class_hashref;
#     %ret = (%ret, %$href);
#   }
#   return sort keys %ret;
# }


1;
__END__

