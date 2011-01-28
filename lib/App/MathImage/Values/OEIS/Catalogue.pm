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
use warnings;
use Module::Pluggable require => 1;
use Locale::TextDomain 'App-MathImage';

use vars '$VERSION';
$VERSION = 43;

# uncomment this to run the ### lines
#use Smart::Comments;

sub anum_to_class {
  my ($class, $anum) = @_;
  ### anum_to_class(): @_
  my @ret;
  foreach my $plugin ($class->plugins) {
    ### $plugin
    my $href = $plugin->anum_to_class_hashref;
    if (my $aref = $href->{$anum}) {
      return @$aref;
    }
  }
  foreach my $file_anum ($class->file_anum_list) {
    if ($anum eq $file_anum) {
      return ['OEIS','anum',$anum];
    }
  }
  return;
}

sub anum_to_class_hashref {
  my ($class) = @_;
  my $dir = App::MathImage::Values::OEIS::File::oeis_dir();
  ### $dir
  my %ret;
  if (opendir DIR, $dir) {
    while (defined (my $basename = readdir DIR)) {
      ### $basename
      if ($basename =~ /^A([0-9]+)\.html?$/i
          || $basename =~ /^[ab]([0-9]+)\.txt?$/i) {
        my $anum = "A$1";
        $ret{$anum} = [ 'OEIS', 'anum', $anum ];
      }
    }
    foreach my $anum (_file_anum_list()) {
      $ret{$anum} ||= ['OEIS','anum',$anum];
    }
    closedir DIR or die "Error closing $dir: $!";
  } else {
    ### cannot opendir: $!
  }
  return \%ret;
}

sub _file_anum_list {
  my ($class) = @_;
  ### anum_list()
  my %ret;
  foreach my $plugin ($class->plugins) {
    ### $plugin
    my $href = $plugin->anum_to_class_hashref;
    %ret = (%ret, %$href);
  }
  return sort keys %ret;
}


1;
__END__

