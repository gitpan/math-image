#!perl -w

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

use 5.004;
use strict;
use warnings;
use Data::Dumper;
use Module::Util;

use vars '$VERSION';
$VERSION = 55;

# uncomment this to run the ### lines
#use Smart::Comments;

my $outfilename = 'lib/App/MathImage/NumSeq/OeisCatalogue/Plugin/BuiltinTable.pm';

my %seen;
my $exit_code = 0;

my @info_arrayref;
my @classes = Module::Util::find_in_namespace('App::MathImage::NumSeq::Sequence');
@classes = sort @classes;
foreach my $class (@classes) {
  # next if $class =~ /^App::MathImage::NumSeq::Sequence::.*::/; # not sub-parts

  my $filename = Module::Util::find_installed($class) or die;
  ### $filename
  open my $in, '<', $filename or die;
  while (<$in>) {
    chomp;
    my $where = "$filename:$.";
    my ($anum, $parameters, $comment);
    if (/^# OeisCatalogue: /) {
      ### OeisCatalogue
      ($anum, $parameters, $comment) = /^# OeisCatalogue: (A[0-9]+)\s*(.*?)(#.*)?$/
        or die "$where: oops, bad OEIS line: $_";
    } elsif (/^use constant oeis_anum\W/) {
      ### use constant
      ($anum, $comment) = /^use constant oeis_anum\s*=>\s*['"]?(.*?)['"].*?(#.*)?/
        or die "$where: oops, bad OEIS line: $_";
      $parameters = '';
    } else {
      next;
    }
    ### $anum
    ### $parameters
    ### $comment

    $anum or die "$where: oops, no OEIS number: $_";

    my @parameters = split /[,= \t]+/, $parameters;
    if (@parameters & 1) {
      die "Oops, odd number of  OEIS params: $_";
    }
    defined $class
      or die "$filename:$.: oops, no \"package\" line";
    if ($seen{$anum}) {
      print STDERR "$where: duplicate of $anum\n$seen{$anum}: is here\n";
      $exit_code = 1;
      next;
    }
    $seen{$anum} = $where;
    push @info_arrayref,
      {
       anum  => $anum,
       class => $class,
       (scalar(@parameters) ? (parameters_hashref => {@parameters}) : ()),
      };
  }
  close $in or die;
}

my $dump = Data::Dumper->new([\@info_arrayref])->Sortkeys(1)->Terse(1)->Indent(1)->Dump;
# $dump =~ s/^{\n//;
# $dump =~ s/}.*\n//;
$dump =~ s/'(\d+)'/$1/g;

open my $out, '>', $outfilename
  or die "Cannot create $outfilename: $!";
print $out <<"HERE";
# Copyright 2011 Kevin Ryde

# Generated by make-oeis-catalogue.pl -- DO NOT EDIT

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

package App::MathImage::NumSeq::OeisCatalogue::Plugin::BuiltinTable;
use strict;
use warnings;

use vars '\$VERSION', '\@ISA';
\$VERSION = $VERSION;
use App::MathImage::NumSeq::OeisCatalogue::Base;
\@ISA = ('App::MathImage::NumSeq::OeisCatalogue::Base');

use constant info_arrayref =>
HERE

print $out "$dump;\n1;\n__END__\n";
exit 0;
