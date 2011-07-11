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



# ->anum_to_inverse
# ->dbi




package App::MathImage::Values::OeisCatalogue;
use 5.004;
use strict;
use List::Util;

# uncomment this to run the ### lines
#use Smart::Comments;

use Module::Pluggable require => 1;
my @plugins = sort __PACKAGE__->plugins;
### @plugins

use vars '$VERSION';
$VERSION = 63;

# sub seq_to_num {
#   my ($class, $num) = @_;
# }


sub anum_to_info {
  my ($class, $num) = @_;
  foreach my $plugin (@plugins) {
    ### $plugin
    if (my $info = $plugin->anum_to_info($num)) {
      return $info;
    }
  }
  return undef;
}

sub anum_list {
  my ($class, $num) = @_;
  my %ret;
  foreach my $plugin (@plugins) {
    ### $plugin
    foreach my $info (@{$plugin->info_arrayref}) {
      $ret{$info->{'anum'}} = 1;
    }
  }
  my @ret = sort {$a<=>$b} keys %ret;
  return @ret;
}

sub _method_apply {
  my $acc = shift;
  my $method = shift;
  return $acc->(grep {defined} map {$_->$method(@_)} @plugins);
}
sub anum_after {
  my ($class, $after_anum) = @_;
  _method_apply (\&List::Util::minstr, 'anum_after', $after_anum);
}
sub anum_before {
  my ($class, $before_anum) = @_;
  _method_apply (\&List::Util::maxstr, 'anum_before', $before_anum);
}

sub anum_first {
  my ($class) = @_;
  _method_apply (\&List::Util::minstr, 'anum_first');
}
sub anum_last {
  my ($class) = @_;
  _method_apply (\&List::Util::maxstr, 'anum_last');
}


# sub anum_to_class {
#   my ($class, $anum) = @_;
#   ### anum_to_class(): @_
#   my @ret;
#   foreach my $plugin (@plugins) {
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
#   foreach my $plugin (@plugins) {
#     ### $plugin
#     my $href = $plugin->anum_to_class_hashref;
#     %ret = (%ret, %$href);
#   }
#   return sort keys %ret;
# }


1;
__END__

